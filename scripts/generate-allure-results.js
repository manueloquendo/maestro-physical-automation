const fs = require("fs");
const path = require("path");
const crypto = require("crypto");

const junitPath = process.argv[2] || "reports/maestro/junit.xml";
const debugRoot = process.argv[3] || "reports/maestro/debug/.maestro/tests";
const outDir = process.argv[4] || "allure-results";

if (!fs.existsSync(junitPath)) {
  throw new Error(`JUnit report not found at ${junitPath}. Run the tests first.`);
}

fs.rmSync(outDir, { recursive: true, force: true });
fs.mkdirSync(outDir, { recursive: true });

const xml = fs.readFileSync(junitPath, "utf8");

function decodeXmlEntities(text) {
  return text
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&quot;/g, '"')
    .replace(/&apos;/g, "'")
    .replace(/&#xd;/gi, "")
    .replace(/&amp;/g, "&");
}

// Find the most recent debug artifact folder for this run (Maestro timestamps each run).
function findLatestDebugRunDir() {
  if (!fs.existsSync(debugRoot)) return null;
  const entries = fs.readdirSync(debugRoot, { withFileTypes: true })
    .filter((e) => e.isDirectory())
    .map((e) => e.name)
    .sort();
  if (entries.length === 0) return null;
  return path.join(debugRoot, entries[entries.length - 1]);
}

const latestDebugRunDir = findLatestDebugRunDir();

const deviceMatch = xml.match(/<testsuite\b[^>]*\bdevice="([^"]*)"/);
const deviceName = deviceMatch ? deviceMatch[1] : "unknown-device";

const testcaseRegex = /<testcase\b([^>]*)>([\s\S]*?)<\/testcase>|<testcase\b([^>]*)\/>/g;
const attrRegex = /(\w+)="([^"]*)"/g;

function parseAttrs(attrString) {
  const attrs = {};
  let match;
  while ((match = attrRegex.exec(attrString)) !== null) {
    attrs[match[1]] = match[2];
  }
  return attrs;
}

let match;
let testCount = 0;

while ((match = testcaseRegex.exec(xml)) !== null) {
  const attrString = match[1] !== undefined ? match[1] : match[3];
  const body = match[2] || "";
  const attrs = parseAttrs(attrString);

  const tagsMatch = body.match(/property name="tags" value="([^"]*)"/);
  const tags = tagsMatch ? tagsMatch[1].split(",").map((t) => t.trim()).filter(Boolean) : [];

  const failureMatch = body.match(/<failure>([\s\S]*?)<\/failure>/);
  const status = failureMatch ? "failed" : "passed";

  const startMs = Date.parse(attrs.timestamp) || Date.now();
  const durationMs = Math.round(parseFloat(attrs.time || "0") * 1000);
  const stopMs = startMs + durationMs;

  const uuid = crypto.randomUUID();
  const labels = [
    { name: "suite", value: "Maestro Android USB" },
    { name: "framework", value: "Maestro" },
    { name: "host", value: deviceName },
    ...tags.map((tag) => ({ name: "tag", value: tag })),
  ];

  const attachments = [];

  if (latestDebugRunDir) {
    const flowDebugDir = path.join(latestDebugRunDir, attrs.name || attrs.id);
    const screenshotsDir = path.join(flowDebugDir, "screenshots");
    if (fs.existsSync(screenshotsDir)) {
      for (const file of fs.readdirSync(screenshotsDir)) {
        const attachmentUuid = crypto.randomUUID();
        const ext = path.extname(file);
        const destName = `${attachmentUuid}-attachment${ext}`;
        fs.copyFileSync(path.join(screenshotsDir, file), path.join(outDir, destName));
        attachments.push({ name: `Screenshot: ${file}`, source: destName, type: "image/png" });
      }
    }

    const recordingDir = path.join(flowDebugDir, "startRecording");
    if (fs.existsSync(recordingDir)) {
      for (const file of fs.readdirSync(recordingDir)) {
        const filePath = path.join(recordingDir, file);
        if (fs.statSync(filePath).size === 0) continue;
        const attachmentUuid = crypto.randomUUID();
        const destName = `${attachmentUuid}-attachment.mp4`;
        fs.copyFileSync(filePath, path.join(outDir, destName));
        attachments.push({ name: `Recording: ${file}`, source: destName, type: "video/mp4" });
      }
    }
  }

  const result = {
    uuid,
    historyId: attrs.id || attrs.name,
    name: attrs.name || attrs.id,
    fullName: attrs.classname || attrs.name,
    status,
    stage: "finished",
    start: startMs,
    stop: stopMs,
    labels,
    attachments,
  };

  if (failureMatch) {
    const rawMessage = decodeXmlEntities(failureMatch[1]).trim();
    const firstLine = rawMessage.split("\n")[0];
    result.statusDetails = { message: firstLine, trace: rawMessage };
  }

  fs.writeFileSync(path.join(outDir, `${uuid}-result.json`), JSON.stringify(result, null, 2));
  testCount += 1;
}

console.log(`Generated ${testCount} Allure result(s) in ${outDir}.`);
