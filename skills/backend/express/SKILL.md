---
name: express
description: Convenção para uma API Node/Express standalone de apoio a uma SPA — lógica sensível a segredo (SMTP, chaves de terceiro) que não pode rodar no browser. Invoque ao criar ou revisar essa API de apoio, ou ao decidir onde colocar lógica que precisa de segredo num projeto frontend-only.
---

# Express (API de apoio)

Quando um projeto frontend-only (`frontend/tailwind`/`frontend/shadcn-ui`, sem backend próprio como
`backend/django-drf`) precisa de algo que não pode rodar no browser — enviar e-mail, falar com um
serviço de terceiro com segredo, qualquer coisa que exigiria expor uma chave — essa lógica vive numa
API própria separada do bundle do frontend, **nunca** em `src/` nem numa env var `VITE_*` (que entra
no bundle público).

## Regras inegociáveis

- Serviço Node standalone (Express) com seu próprio `package.json`, `tsconfig.json`, `.env`/
  `.env.example` e `Dockerfile`, deployado como serviço separado (Vercel Function, container Docker
  no Coolify/Railway/Fly, etc.) — não é um backend completo, é uma API de apoio pequena e focada.
- O frontend fala com essa API via `fetch`/`axios`, apontando pra URL configurável por env var
  (`VITE_API_URL`), com fallback pra um proxy de dev no `vite.config.ts` quando frontend e API rodam
  juntos localmente:
  ```ts
  server: {
    proxy: {
      '/api': { target: 'http://localhost:3001', rewrite: (p) => p.replace(/^\/api/, '') },
    },
  },
  ```
- Toda validação de input do usuário é refeita no backend (zod ou equivalente) mesmo que o frontend
  já valide — o backend nunca confia em payload de cliente.
- Qualquer texto de usuário que entra em HTML gerado pelo backend (ex.: corpo de e-mail) precisa ser
  escapado — não interpole string crua em template HTML.
- Segredo (SMTP, API key de terceiro) só via env var do próprio serviço, nunca commitado, nunca
  repassado ao frontend em nenhuma resposta.

## Skills relacionadas

- Frontend que consome esta API: `frontend/tailwind`, `frontend/shadcn-ui`
- Env vars e proxy de dev do lado frontend: `frontend/vite`
