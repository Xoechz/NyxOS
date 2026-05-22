---
name: angular-dev
description: Angular 20+ and TypeScript conventions — signals, standalone components, reactive forms, accessibility.
compatibility: opencode
---

## Stack

- Angular 20+ (standalone components default — do NOT set `standalone: true` in decorators)
- TypeScript strict mode

## TypeScript

- Strict type checking always on
- Prefer type inference when type obvious
- Never use `any`; use `unknown` when type uncertain

## Components

- `changeDetection: ChangeDetectionStrategy.OnPush` always
- Use `input()` / `output()` functions, not decorators
- Use `computed()` for derived state
- Signals for all local state — no `mutate`, use `update` or `set`
- `class` bindings instead of `ngClass`; `style` bindings instead of `ngStyle`
- No `@HostBinding` / `@HostListener` — put host bindings in `host` object of `@Component` / `@Directive`
- Inline templates for small components; external paths relative to component TS file
- Reactive forms, not template-driven

## Templates

- Native control flow: `@if`, `@for`, `@switch` — not `*ngIf`, `*ngFor`, `*ngSwitch`
- Async pipe for observables
- No globals (e.g. `new Date()`) in templates
- No arrow functions in templates

## Images

- `NgOptimizedImage` for all static images (not inline base64)

## Services

- Single responsibility
- `providedIn: 'root'` for singletons
- `inject()` function, not constructor injection

## Accessibility

- Must pass all AXE checks
- WCAG AA: focus management, color contrast, ARIA attributes

## Building

Do not build! Building and running tests is reserved for the developer, except when explicitly requested.

Use only the LSP for checking.