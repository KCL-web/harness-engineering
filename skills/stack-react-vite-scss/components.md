# Componentes

- Uma pasta por componente (`.tsx` + `.module.scss` + `.test.tsx`).
- Export **nomeado**, não `default`, para componentes não-page.
- Props tipadas com `interface`, nunca com `type` inline anônimo.
- Nunca importe CSS global dentro de um componente — use **SCSS Modules**.
- Nunca use inline styles (`style={{}}`).

```tsx
// Button/Button.tsx
import styles from './Button.module.scss';

interface ButtonProps {
  label: string;
  variant?: 'primary' | 'secondary';
  onClick: () => void;
}

export function Button({ label, variant = 'primary', onClick }: ButtonProps) {
  return (
    <button
      className={`${styles.button} ${styles[`button--${variant}`]}`}
      onClick={onClick}
    >
      {label}
    </button>
  );
}
```

## BEM + SCSS Modules

BEM dentro de SCSS Modules: o escopo do arquivo já evita colisão global.

```scss
// Button.module.scss
.button {
  padding: 8px 16px;
  border-radius: 4px;

  &--primary   { background: var(--color-primary); color: #fff; }
  &--secondary { background: transparent; border: 1px solid var(--color-primary); }

  &__icon { margin-right: 8px; }

  
}
```

Uso no `.tsx`:
```tsx
// elemento + modifier
<button className={`${styles.button} ${styles['button--primary']}`} />

// elemento filho
<span className={styles.button__icon} />
```

Quando o modifier é dinâmico, prefira `clsx` ou template literal em vez de concatenação manual:
```tsx
import clsx from 'clsx';
<button className={clsx(styles.button, styles[`button--${variant}`])} />
```

## Campos de formulário (Input, Textarea, Select)

Todo campo de formulário global (`Input`, `Textarea`, `Select`, etc. em `src/components/`) segue um contrato fixo:

- **`label` e `error` são sempre props** — o componente nunca recebe label ou mensagem de erro via `children`, só via parâmetro. Isso é o que permite reuso: o form só passa dados, o componente decide como renderizar.
- **`<label>` e `<span role="alert">` do erro já vêm embutidos no componente**, condicionados a `error` estar presente — nenhum form escreve `{errors.campo && <span>...}` manualmente (ver `forms.md`).
- **`error` é sempre a `message` do zod** (`errors.campo?.message` do RHF) — o componente não sabe nem precisa saber que existe zod, só recebe a string pronta.
- **`forwardRef` obrigatório** — o `ref` do `register()` do RHF precisa chegar ao elemento nativo.
- Demais props (`name`, `onChange`, `onBlur`, `type`, `placeholder`, …) são o spread de `...register(campo)` mais o que o form passar — o componente as repassa para o elemento nativo sem reinterpretar.

```tsx
// Input/Input.tsx
import { forwardRef, type InputHTMLAttributes } from 'react';
import styles from './Input.module.scss';

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  label: string;
  error?: string;
}

export const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ label, error, id, name, ...props }, ref) => {
    const inputId = id ?? name;
    return (
      <div className={styles.field}>
        <label htmlFor={inputId} className={styles.label}>{label}</label>
        {/* Tag bruta só é aceitável aqui: esta é a definição do componente global.
            Qualquer form com 2+ inputs deve consumir este componente, nunca repetir <input> cru. */}
        <input id={inputId} name={name} ref={ref} className={styles.input} {...props} />
        {error && <span role="alert" className={styles.error}>{error}</span>}
      </div>
    );
  },
);
Input.displayName = 'Input';
```

`Textarea` e `Select` seguem exatamente o mesmo contrato (`label`, `error`, `forwardRef`), só trocando o elemento nativo interno.
