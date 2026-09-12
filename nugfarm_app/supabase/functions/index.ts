import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

function jsonResponse(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return jsonResponse({ error: "Tidak ada token otorisasi" }, 401);
    }

    // Client dengan token caller, buat verifikasi siapa yang manggil
    const callerClient = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
      global: { headers: { Authorization: authHeader } },
    });

    const { data: userData, error: userErr } = await callerClient.auth.getUser();
    if (userErr || !userData?.user) {
      return jsonResponse({ error: "Token tidak valid" }, 401);
    }
    const callerId = userData.user.id;

    // Admin client (service role) buat semua operasi privileged
    const adminClient = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

    const { data: callerProfil, error: profilErr } = await adminClient
      .from("tbl_profil")
      .select("role")
      .eq("id", callerId)
      .single();

    if (profilErr || callerProfil?.role !== "admin") {
      return jsonResponse({ error: "Hanya admin yang boleh mengelola petugas" }, 403);
    }

    const body = await req.json();
    const action = body.action;

    if (action === "create") {
      const { nama, email, password } = body;
      if (!nama || !email || !password) {
        return jsonResponse({ error: "nama, email, password wajib diisi" }, 400);
      }

      const { data: created, error: createErr } = await adminClient.auth.admin.createUser({
        email,
        password,
        email_confirm: true,
      });
      if (createErr) return jsonResponse({ error: createErr.message }, 400);

      const newUserId = created.user!.id;

      // Trigger sudah auto-insert baris tbl_profil default, tinggal di-update
      const { error: updateErr } = await adminClient
        .from("tbl_profil")
        .update({ nama, role: "petugas", email, aktif: true })
        .eq("id", newUserId);
      if (updateErr) return jsonResponse({ error: updateErr.message }, 400);

      return jsonResponse({ success: true, id: newUserId });
    }

    if (action === "deactivate" || action === "reactivate") {
      const { id } = body;
      if (!id) return jsonResponse({ error: "id wajib diisi" }, 400);

      const banDuration = action === "deactivate" ? "876000h" : "0h"; // ~100 tahun vs cabut ban

      const { error: banErr } = await adminClient.auth.admin.updateUserById(id, {
        ban_duration: banDuration,
      });
      if (banErr) return jsonResponse({ error: banErr.message }, 400);

      const { error: updateErr } = await adminClient
        .from("tbl_profil")
        .update({ aktif: action === "reactivate" })
        .eq("id", id);
      if (updateErr) return jsonResponse({ error: updateErr.message }, 400);

      return jsonResponse({ success: true });
    }

    if (action === "delete") {
      const { id } = body;
      if (!id) return jsonResponse({ error: "id wajib diisi" }, 400);

      const { error: deleteErr } = await adminClient.auth.admin.deleteUser(id);
      if (deleteErr) return jsonResponse({ error: deleteErr.message }, 400);

      return jsonResponse({ success: true });
    }

    return jsonResponse({ error: "action tidak dikenal" }, 400);
  } catch (e) {
    return jsonResponse({ error: String(e) }, 500);
  }
});
