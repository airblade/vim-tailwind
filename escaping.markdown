# Escaping

The fastest way to load the Tailwind CSS into Vim is via JSON.  The process is:

1. Generate CSS.
2. Convert CSS to JSON; in the process convert the CSS class names to Tailwind class names..
3. [Vim] load JSON.
4. [Vim] match against Tailwind class names.

| Tailwind class name | CSS class name |
|--|--|--|
| `p-0.5` | `p-0\.5` |

