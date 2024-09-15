import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.0.0";

console.log("Delete user account function up and running");

serve(async (req) => {
  try {
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "https://tujdrdrybiusritiatvg.supabase.co",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR1amRyZHJ5Yml1c3JpdGlhdHZnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcyMzAwMzM2NCwiZXhwIjoyMDM4NTc5MzY0fQ.xxNMbK1ONbgFVuOk7u4coR1XYbdUQG8BaKHc6OQORsc",
    );

    const authHeader = req.headers.get("Authorization");

    if (!authHeader) {
      throw new Error("No Authorization header found");
    }

    const jwt = authHeader.replace("Bearer ", "");

    const { data: { user } } = await supabaseClient.auth.getUser(jwt);

    if (!user) throw new Error("No user found for JWT!");

    // Delete the user profile first
    await supabaseClient
      .from('profiles')
      .delete()
      .eq('id', user.id);

    // Delete the user account from auth.users
    const { error } = await supabaseClient.auth.admin.deleteUser(user.id);

    if (error) throw error;

    return new Response(JSON.stringify({ message: 'User account deleted' }), {
      headers: { "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { "Content-Type": "application/json" },
      status: 400,
    });
  }
});

