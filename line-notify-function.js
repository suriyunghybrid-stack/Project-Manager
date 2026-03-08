// ══════════════════════════════════════════════════════════════
//  Supabase Edge Function: line-notify
//  วิธีใช้:
//  1. ติดตั้ง Supabase CLI: npm install -g supabase
//  2. supabase functions new line-notify
//  3. คัดลอก code นี้ไปใส่ใน supabase/functions/line-notify/index.ts
//  4. supabase functions deploy line-notify --no-verify-jwt
// ══════════════════════════════════════════════════════════════

// supabase/functions/line-notify/index.ts
/*
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { token, message } = await req.json()
    
    if (!token || !message) {
      return new Response(
        JSON.stringify({ error: 'token and message are required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const response = await fetch('https://notify-api.line.me/api/notify', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: `message=${encodeURIComponent(message)}`,
    })

    const result = await response.text()
    
    return new Response(
      JSON.stringify({ success: response.ok, status: response.status, result }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
*/

// ══════════════════════════════════════════════════════════════
//  วิธีขอ LINE Notify Token:
//  1. ไปที่ https://notify-bot.line.me/my/
//  2. Login ด้วย LINE account
//  3. กด "Generate token"
//  4. ตั้งชื่อ notification และเลือก chat ที่ต้องการรับ
//  5. Copy token ไปใส่ใน ProjectPro Settings
// ══════════════════════════════════════════════════════════════
