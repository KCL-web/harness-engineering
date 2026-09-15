---
name: infra-forgejo-coolify
description: Topologia de rede do Forgejo (interno, sem IP público) e do Coolify (VPS), ligados por uma tailnet Tailscale — inclusive o webhook de deploy. Referência para devs fazendo manutenção de infra; não é um workflow de código. Invoque quando o dev perguntar por que o Forgejo não responde por IP direto, como o deploy automático dispara, ou pedir os endereços da tailnet.
---

# Infra: Forgejo + Coolify via tailnet

Esta skill é **referência de infraestrutura para devs**, não uma convenção de workflow de código —
existe aqui porque este repo é privado (autenticação obrigatória) e é a fonte que a
`engineering-knowledge-platform` consome para publicar conhecimento interno.

## Topologia

- **Forgejo** (`git.kcl.net.br`) roda na rede interna da empresa. Tem IP de LAN
  `192.168.0.130`, que **não é alcançável de fora** — não existe port-forward nem IP público
  apontando pra ele.
- **Coolify** roda numa **VPS** externa, fora da rede da empresa.
- As duas máquinas (e outros dispositivos do time) estão na mesma **tailnet Tailscale**
  (`KCL-web`). É por ela que Coolify alcança o Forgejo, e vice-versa — não existe caminho de
  rede entre os dois fora da tailnet.

## Inventário da tailnet (nós relevantes pra infra)

| IP tailnet | Hostname | Papel |
| --- | --- | --- |
| `100.95.217.25` | `forgejo` | Forgejo — mesma máquina do IP de LAN `192.168.0.130`, alcançável só via tailnet ou de dentro da rede interna |
| `100.94.228.110` | `17141` (hostname padrão, nunca renomeado) | VPS que roda o **Coolify** |

> Existem outros nós na tailnet (ex.: laptops de dev, outro serviço com hostname `coolify` em
> `100.96.30.15` que é distinto da VPS acima) — fora do escopo desta skill. Para o inventário
> completo e atualizado, rode `tailscale status` numa máquina já conectada, ou veja o
> [admin console do Tailscale](https://login.tailscale.com/admin/machines).

## Webhook de deploy (Forgejo → Coolify)

O deploy automático (push/merge num projeto) dispara via **webhook do Forgejo apontando pro
Coolify**, e esse tráfego **passa pela tailnet** — é o único jeito de um evento do Forgejo (rede
interna, sem IP público) alcançar a VPS do Coolify sem expor o Forgejo pra internet.

Isso implica, ao diagnosticar "deploy não disparou":

1. Confirme que ambos os nós (`forgejo` e a VPS do Coolify) aparecem **online** em
   `tailscale status` — se um dos dois caiu da tailnet, o webhook não chega.
2. A URL do webhook configurada no Forgejo (Settings do repo → Webhooks) aponta pro **IP/hostname
   tailnet** do Coolify, não pro IP público da VPS nem pra um domínio — confirme isso se o webhook
   foi reconfigurado recentemente.
3. Logs do lado que recebe (Coolify) e do lado que dispara (Forgejo → aba Webhooks da issue/PR,
   mostra o histórico de entregas e o código de resposta) são o primeiro lugar a olhar.

## Por que isso importa pra manutenção

- **Serviço novo que precisa falar com o Forgejo** (outro webhook, integração, script de CI
  rodando fora da rede interna): aponte para o **IP/hostname tailnet** (`100.95.217.25` /
  `forgejo`), nunca para `192.168.0.130` — esse só resolve de dentro da LAN da empresa.
- **IP tailnet pode mudar** se o dispositivo for removido/re-adicionado à tailnet (o Tailscale
  tenta manter o mesmo IP, mas não é garantido). Antes de hardcodar um IP em config de produção,
  prefira o **hostname MagicDNS** (`forgejo.<tailnet>.ts.net`) quando disponível, ou confirme o IP
  atual com `tailscale status` em vez de confiar num valor documentado antigo.
- **VPS do Coolify tem hostname genérico (`17141`)** — ninguém renomeou ainda. Vale considerar
  renomear para algo como `coolify-vps` no admin console do Tailscale, pra reduzir a chance de
  alguém confundir com outro nó numérico da lista.

## Skills relacionadas

- Nenhuma diretamente — esta é referência de infra, não de workflow de código. Ver `harness-index`
  para o índice geral de skills do harness.
