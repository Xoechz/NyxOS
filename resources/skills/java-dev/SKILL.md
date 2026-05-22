---
name: java-dev
description: Java conventions on NixOS — JDK 25 default, JDK 8 available, Maven and Gradle commands, google-java-format.
compatibility: opencode
---

## Environment

- Default JDK: 25 (`JAVA_HOME`, `JAVA_25_HOME`)
- Legacy JDK: 8 (`JAVA_8_HOME`)
- Build tools: `ant`, `mvn`, `gradle`, `./gradlew` (prefer wrapper)

## Switching JDK

```bash
JAVA_HOME=$JAVA_8_HOME mvn test   # single command with JDK 8
java -version                      # check active version
```

## Maven & Gradle

Do not build! Building and running tests is reserved for the developer, except when explicitly requested.

Use only the LSP for checking.

## Build tool detection

- `pom.xml` present → Maven
- `build.gradle` / `build.gradle.kts` present → Gradle
- Always prefer `./gradlew` over system `gradle`

## Code style

- Target Java 25 unless project specifies lower `--release`
- Use records, sealed classes, pattern matching where idiomatic
- Maven: declare `<java.version>` in `<properties>`, reference in `maven-compiler-plugin`
