```text
docs/tdd/
├── README.md
├── architecture/
│   ├── system-context.md
│   ├── service-map.md
│   └── data-ownership.md
├── decisions/
│   └── ADR-001-decision-name.md
├── cross-cutting/
│   ├── security.md
│   ├── observability.md
│   └── reliability.md
├── features/
│   └── TDD-FEAT-001-feature-name.md
└── services/
    └── service-name/
        ├── TDD.md
        ├── openapi.yaml
        ├── asyncapi.yaml
        └── schemas/
```

Create only artifacts needed by the design. A small feature can use one TDD; split feature orchestration from service internals when complexity or reuse warrants it. Keep existing canonical contract locations and link them from the owning design.
