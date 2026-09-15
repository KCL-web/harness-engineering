---
name: tailwind
description: Convenção de estilo Tailwind CSS para componentes React. Invoque ao estilizar um componente em projeto que usa este archetype.
---

# Tailwind CSS

Classes utilitárias direto no JSX. Sem arquivo `.module.css`/`.scss` por componente — a única folha
de estilo do projeto é `src/index.css` (ou `src/styles/index.css`), e só existe para o que Tailwind
não cobre (reset, `@font-face`, tokens custom via `@theme` ou CSS custom properties).

Componente de página/seção é **um arquivo solto** (`FooSection.tsx`), sem pasta própria — diferente de
`frontend/scss-bem`, aqui não há arquivo de estilo irmão que justifique uma pasta.

```tsx
// components/PricingCard.tsx
import { cn } from '@/lib/utils';

interface PricingCardProps {
  title: string;
  variant?: 'primary' | 'secondary';
  onSelect: () => void;
}

export function PricingCard({ title, variant = 'primary', onSelect }: PricingCardProps) {
  return (
    <button
      onClick={onSelect}
      className={cn(
        'rounded-lg px-4 py-2 text-sm font-medium transition',
        variant === 'primary' && 'bg-primary text-primary-foreground',
        variant === 'secondary' && 'border border-border hover:bg-muted',
      )}
    >
      {title}
    </button>
  );
}
```

## Regras inegociáveis

- Use sempre `cn()` (wrapper de `clsx` + `tailwind-merge`, em `@/lib/utils`) para compor classes
  condicionais — nunca concatenação manual de string (`'btn ' + (active ? 'active' : '')`), que não
  resolve conflito entre classes Tailwind (`tailwind-merge` resolve).
- Combinação condicional de classes via `cva` (`class-variance-authority`) quando há 3+ variantes;
  `cn()` simples é suficiente para 1-2 condicionais.
- Mesma sequência de utilitárias repetida em 3+ componentes é sinal de que virou um componente
  (`<Card>`, `<Badge>`) — não uma constante de string de classes.
- Sem `style={{ ... }}` inline. Exceção: valor verdadeiramente dinâmico que não dá pra expressar em
  classe (ex. `style={{ width: \`${progress}%\` }}`).
- Tokens de design (cores de marca, espaçamento fora da escala padrão) vivem como CSS custom
  properties/`@theme` no CSS global, não espalhados como valores mágicos (`bg-[#1a2b3c]`) pelos
  componentes.

## Skills relacionadas

- Estrutura de componente: `frontend/react`
- Componentes gerados via CLI (Radix + `cva`): `frontend/shadcn-ui`
