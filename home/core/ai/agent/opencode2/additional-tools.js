// Keep the host's tool registry unchanged; only change the HTTP wire layout.
const models = new Set(['gpt-6-astra', 'gpt-6.1-sol']);

export default {
  id: 'openai-additional-tools',
  async setup(ctx) {
    const registration = await ctx.session.hook(
      'http.request',
      async (event) => {
        if (event.model.providerID !== 'openai') return;
        const request = event.request;
        if (request.method !== 'POST') return;
        if (!new URL(request.url).pathname.endsWith('/responses')) return;
        if (!request.headers.get('content-type')?.includes('application/json')) return;

        const body = await request.clone().json();
        if (!models.has(body.model)) return;
        if (!Array.isArray(body.tools) || body.tools.length === 0) return;
        if (!Array.isArray(body.input)) return;

        // Stable placement, original tool names/schema/order, no generated IDs.
        body.input = [
          { type: 'additional_tools', role: 'developer', tools: body.tools },
          ...body.input,
        ];
        delete body.tools;

        const headers = new Headers(request.headers);
        headers.delete('content-length');
        event.request = new Request(request, {
          headers,
          body: JSON.stringify(body),
        });
      },
      { providerID: 'openai' },
    );
    return () => registration.dispose();
  },
};
