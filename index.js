#!/usr/bin/env node

/**
 * ProjectPro MCP Server
 * เชื่อมต่อ Claude กับ ProjectPro (Supabase)
 */

const SUPABASE_URL = process.env.SUPABASE_URL || "https://rsprwdtbcfagieduwkon.supabase.co";
const SUPABASE_KEY = process.env.SUPABASE_KEY || "";

// ─── Supabase REST helper ─────────────────────────────────────
async function supabase(table, options = {}) {
  const { method = "GET", filter = "", body = null, select = "*" } = options;
  let url = `${SUPABASE_URL}/rest/v1/${table}?select=${select}`;
  if (filter) url += `&${filter}`;

  const res = await fetch(url, {
    method,
    headers: {
      apikey: SUPABASE_KEY,
      Authorization: `Bearer ${SUPABASE_KEY}`,
      "Content-Type": "application/json",
      Prefer: method === "POST" ? "return=representation" : "",
    },
    body: body ? JSON.stringify(body) : undefined,
  });

  if (!res.ok) {
    const err = await res.text();
    throw new Error(`Supabase error: ${err}`);
  }
  return res.json();
}

// ─── MCP Protocol ─────────────────────────────────────────────
const tools = [
  {
    name: "get_projects",
    description: "ดึงรายการ Projects ทั้งหมด พร้อมสถานะและวันที่",
    inputSchema: { type: "object", properties: {}, required: [] },
  },
  {
    name: "get_tasks",
    description: "ดึงรายการ Tasks ทั้งหมด กรองตาม project หรือ status ได้",
    inputSchema: {
      type: "object",
      properties: {
        project_id: { type: "number", description: "ID ของ project (ไม่บังคับ)" },
        status: { type: "string", description: "todo | inprogress | review | done (ไม่บังคับ)" },
      },
      required: [],
    },
  },
  {
    name: "create_project",
    description: "สร้าง Project ใหม่",
    inputSchema: {
      type: "object",
      properties: {
        name: { type: "string", description: "ชื่อ Project เช่น MODIFY C/F P/NO.MB3B-xxx" },
        description: { type: "string", description: "รายละเอียด" },
        start_date: { type: "string", description: "วันเริ่ม (YYYY-MM-DD)" },
        end_date: { type: "string", description: "วันส่งงาน (YYYY-MM-DD)" },
      },
      required: ["name"],
    },
  },
  {
    name: "create_task",
    description: "สร้าง Task ใหม่ในโปรเจค",
    inputSchema: {
      type: "object",
      properties: {
        name: { type: "string", description: "ชื่องาน เช่น ออกแบบ 3D" },
        project_id: { type: "number", description: "ID ของ project" },
        status: { type: "string", description: "todo | inprogress | review | done" },
        priority: { type: "string", description: "low | medium | high" },
        due_date: { type: "string", description: "วันครบกำหนด (YYYY-MM-DD)" },
      },
      required: ["name", "project_id"],
    },
  },
  {
    name: "update_task_status",
    description: "อัปเดตสถานะ Task",
    inputSchema: {
      type: "object",
      properties: {
        task_id: { type: "number", description: "ID ของ task" },
        status: { type: "string", description: "todo | inprogress | review | done" },
      },
      required: ["task_id", "status"],
    },
  },
  {
    name: "get_overdue_tasks",
    description: "ดึงรายการ Tasks ที่เกินกำหนดส่งแล้ว",
    inputSchema: { type: "object", properties: {}, required: [] },
  },
  {
    name: "get_team_members",
    description: "ดึงรายชื่อสมาชิกทีมทั้งหมด",
    inputSchema: { type: "object", properties: {}, required: [] },
  },
  {
    name: "get_activities",
    description: "ดึง Activity Log ล่าสุด",
    inputSchema: {
      type: "object",
      properties: {
        limit: { type: "number", description: "จำนวนรายการ (default: 10)" },
      },
      required: [],
    },
  },
];

async function callTool(name, args) {
  switch (name) {
    case "get_projects": {
      const data = await supabase("projects", { select: "*" });
      return data.map(p => `📁 [${p.id}] ${p.name} | สถานะ: ${p.status} | ส่ง: ${p.end_date || "-"}`).join("\n") || "ไม่มีโปรเจค";
    }

    case "get_tasks": {
      let filter = "";
      if (args.project_id) filter += `project_id=eq.${args.project_id}&`;
      if (args.status) filter += `status=eq.${args.status}&`;
      const data = await supabase("tasks", { filter, select: "*" });
      return data.map(t => `✅ [${t.id}] ${t.name} | ${t.status} | priority: ${t.priority} | ครบ: ${t.due_date || "-"}`).join("\n") || "ไม่มี task";
    }

    case "create_project": {
      const data = await supabase("projects", {
        method: "POST",
        body: { name: args.name, description: args.description, start_date: args.start_date, end_date: args.end_date, status: "planning" },
      });
      return `✅ สร้าง Project สำเร็จ! ID: ${data[0]?.id} ชื่อ: ${data[0]?.name}`;
    }

    case "create_task": {
      const data = await supabase("tasks", {
        method: "POST",
        body: { name: args.name, project_id: args.project_id, status: args.status || "todo", priority: args.priority || "medium", due_date: args.due_date },
      });
      return `✅ สร้าง Task สำเร็จ! ID: ${data[0]?.id} ชื่อ: ${data[0]?.name}`;
    }

    case "update_task_status": {
      await supabase(`tasks?id=eq.${args.task_id}`, {
        method: "PATCH",
        body: { status: args.status },
        filter: "",
      });
      return `✅ อัปเดตสถานะ Task ${args.task_id} เป็น "${args.status}" สำเร็จ!`;
    }

    case "get_overdue_tasks": {
      const today = new Date().toISOString().split("T")[0];
      const data = await supabase("tasks", { filter: `due_date=lt.${today}&status=neq.done`, select: "*" });
      return data.map(t => `⚠️ [${t.id}] ${t.name} | ครบ: ${t.due_date} | สถานะ: ${t.status}`).join("\n") || "✅ ไม่มีงานค้างครับ!";
    }

    case "get_team_members": {
      const data = await supabase("team_members", { select: "*" });
      return data.map(m => `👤 [${m.id}] ${m.name} | ตำแหน่ง: ${m.role_title || "-"}`).join("\n") || "ไม่มีสมาชิก";
    }

    case "get_activities": {
      const limit = args.limit || 10;
      const data = await supabase("activities", { filter: `order=created_at.desc&limit=${limit}`, select: "*" });
      return data.map(a => `📝 ${a.text} | ${new Date(a.created_at).toLocaleString("th-TH")}`).join("\n") || "ไม่มี activity";
    }

    default:
      throw new Error(`Unknown tool: ${name}`);
  }
}

// ─── stdio transport ──────────────────────────────────────────
process.stdin.setEncoding("utf8");
let buffer = "";

process.stdin.on("data", async (chunk) => {
  buffer += chunk;
  const lines = buffer.split("\n");
  buffer = lines.pop();

  for (const line of lines) {
    if (!line.trim()) continue;
    try {
      const msg = JSON.parse(line);
      const response = await handleMessage(msg);
      if (response) process.stdout.write(JSON.stringify(response) + "\n");
    } catch (e) {
      // ignore parse errors
    }
  }
});

async function handleMessage(msg) {
  if (msg.method === "initialize") {
    return {
      jsonrpc: "2.0", id: msg.id,
      result: {
        protocolVersion: "2024-11-05",
        capabilities: { tools: {} },
        serverInfo: { name: "projectpro-mcp", version: "1.0.0" },
      },
    };
  }

  if (msg.method === "tools/list") {
    return { jsonrpc: "2.0", id: msg.id, result: { tools } };
  }

  if (msg.method === "tools/call") {
    try {
      const result = await callTool(msg.params.name, msg.params.arguments || {});
      return {
        jsonrpc: "2.0", id: msg.id,
        result: { content: [{ type: "text", text: result }] },
      };
    } catch (e) {
      return {
        jsonrpc: "2.0", id: msg.id,
        result: { content: [{ type: "text", text: `❌ Error: ${e.message}` }], isError: true },
      };
    }
  }

  if (msg.method === "notifications/initialized") return null;
  return { jsonrpc: "2.0", id: msg.id, result: {} };
}
