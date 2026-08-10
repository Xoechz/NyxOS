# Coding Conventions

## Klassendesign (CIT1000)

- CIT1000: Eine Klasse oder ein Interface soll genau eine Verantwortung haben (Single Responsibility Principle).
- CIT1001: Klassen, die mehrere Verantwortlichkeiten oder Konzepte koppeln, aufteilen; Namen mit "and" deuten auf Verletzung hin.
- CIT1002: Erweiterungspunkte als Interface bereitstellen; bei Bedarf eine Standardimplementierung anbieten, aber keine verpflichtende Basisklasse erzwingen.
- CIT1003: Statische Klassen nur verwenden, wenn wirklich nötig; dann zwingend mit dem static-Modifier deklarieren.
- CIT1013: Nicht von einer Basisklasse auf bekannte Subklassen verweisen; Abhängigkeiten nur Richtung Abstraktion (Interfaces/Basistypen).

## Richtlinien für Typ-Members (CIT1100)

- CIT1100: Properties sollen zustandslos sein; das Setzen der Reihenfolge von Properties darf das Objektverhalten nicht beeinflussen.
- CIT1101: Keine aufwändigen Operationen, Seiteneffekte oder non-deterministische Ergebnisse in Properties ausführen; Ausnahmen: Cache-Refresh, Lazy-Loading.
- CIT1102: Öffentlich zurückgegebene Collections niemals als veränderbare Arrays/Lists exposen — stattdessen IReadOnlyCollection/ IReadOnlyList/ IEnumerable verwenden.
- CIT1103: Niemals null für Collections zurückgeben; stattdessen eine leere Collection. Gleiches gilt für Task/Task<T> (z. B. Task.CompletedTask / Task.FromResult()).
- CIT1104: Methoden sollen konkrete Parameter verlangen (z. B. Connection-String), statt ganze Konfigurationsobjekte pauschal zu lesen ("Don’t ship the truck if you only need a package").
- CIT1105: Domänenspezifische Primitive als Value Objects modellieren (z. B. ISBN, Email, Money) statt Rohtypen.

## Sonstige Designrichtlinien (CIT1200)

- CIT1200: Verwende Exceptions zur Fehlerberichterstattung statt return-Codes; Exceptions nur für unerwartete Zustände.
- CIT1201: Beim Werfen von Exceptions spezifische Typen verwenden (z. B. ArgumentNullException bei null-Argumenten), nicht Exception/SystemException allgemein.
- CIT1202: Exception-Message so formulieren, dass Ursache und Vermeidung ersichtlich sind.
- CIT1203: Unspezifische Catch-Blöcke (catch Exception) nur in obersten Schichten für Logging/Beenden verwenden; Anwendungslogik soll spezifische Exceptions behandeln.
- CIT1205: Protected virtual‑Methode zum Auslösen eines Events mit Präfix "On" benennen (z. B. OnTimeChanged).

## Wartbarkeit (CIT1500)

- CIT1500: Kognitive Komplexität begrenzen — Methoden ≤ 15, Properties ≤ 3 (SonarCloud-Orientierung).
- CIT1501: Sichtbarkeit so restriktiv wie möglich wählen; öffentliche API bewusst gestalten.
- CIT1502: Keine mehrfachen (!) Verantwortlichkeiten in Typen/Membern; bei komplexen Zuständen Typen zerlegen.
- CIT1503: Keine auskommentierten Codeblöcke committen — entfernen oder als Issue hinterlegen.
- CIT1504: Verschachtelte Schleifen vermeiden; dort, wo geeignet, LINQ oder klar benannte Hilfsmethoden verwenden.
- CIT1505: Keine harten Literalwerte (magic numbers/strings) im Code verwenden — Konstanten oder konfigurierte Werte nutzen; Ausnahmen für unveränderliche, kontextklare Literale (z. B. Log-Keys).

## Namenskonventionen — Ergänzungen (CIT1700)

- CIT1700: Boolean-Properties positiv benennen und mit Präfixen wie Is/Has/Can/Supports/Allows beginnen (z. B. IsEnabled, HasItems).
- CIT1701: Events mit Verb(-ing) benennen (z. B. Closing, Deleted); für abgeschlossene Aktionen -ed verwenden (Closed, Deleted).
- CIT1702: Event-Handler-Methoden mit "On" + EventName benennen (z. B. OnClosing).
- CIT1703: Extension-Methoden in einer statischen Klasse mit dem Suffix "Extensions" bündeln (z. B. StringExtensions).
- CIT1704: Async‑Suffix nur verwenden, wenn sowohl synchrone als auch asynchrone Varianten koexistieren (z. B. Save / SaveAsync).

## Performancerichtlinien (CIT1800)

- CIT1800: Für Existenzprüfung von Sequenzen Any() statt Count() verwenden, wenn kein O(1)-Count vorhanden ist.
- CIT1801: LINQ-Ergebnisse materialisieren (ToList/ToArray) bevor sie zurückgegeben werden, um unerwartete Mehrfachausführung zu vermeiden; bei I/O‑bound-Abfragen asynchrone Varianten (ToListAsync()) bevorzugen.
- CIT1802: async/await ist für I/O-Bound-Work geeignet; für CPU-Bound-Work Task.Run verwenden; für langlaufende CPU-Tasks Task.Factory.StartNew mit LongRunning in Erwägung ziehen.
- CIT1803: Blockierende Aufrufe wie Task.Wait/Result vermeiden (Deadlock-Gefahr in Single-Thread-Synchronizationskontexten).

## Richtlinien zur Verwendung des .NET (CIT2200)

- CIT2200: dynamic vermeiden; nur für Interop oder sehr spezifische Szenarien einsetzen.
- CIT2201: Tupeltypen (ValueTuples) nur im privaten Bereich verwenden; öffentliche Schnittstellen bevorzugen Records/Klassen.
- CIT2202: Raw-String-Literale (C#11+) für mehrzeilige Strings bevorzugen; Verbatim-Literale nur wenn passend.
- CIT2203: Bei Nutzung von Nullable Reference Types erforderliche Initialisierungen ernst nehmen; ab .NET 7 Required-Members für nicht-nullbare Instanzen nutzen.
- CIT2204: Neue Sprachfeatures (Primary Constructors, Collection Expressions, Using alias types) wohlüberlegt einsetzen — dort bevorzugen, wo Lesbarkeit/Wartbarkeit klar profitieren.

## Kommentarrichtlinien (CIT2300)

- CIT2300: Alle Kommentare in englischer Sprache verfassen.
- CIT2301: Kommentare erklären primär das "Warum" und gegebenenfalls das "Was" — nicht das "Wie".
- CIT2302: XML-Kommentare dort verwenden, wo API-Vertrag/Dokumentation nötig ist; für die Common Class Library (CCL) sind XML-Kommentare verpflichtend.
- CIT2303: Wenn ein Codeblock erklärungsbedürftig ist, lieber in eine gut benannte Methode auslagern statt ausführlich zu kommentieren.

## Formatierungsrichtlinien — Ergänzungen (CIT2400)

- CIT2400: Maximale Zeilenlänge 200 Zeichen einhalten.
- CIT2401: Dateinamen in PascalCase und mit dem enthaltenen Typnamen benennen; bevorzugt ein Typ pro Datei (Ausnahmen: Nested-Types, gleiche Generic-Arity-Varianten).
- CIT2402: Using‑Direktiven alphabetisch sortieren; reguläre using‑Direktiven vor statischen und Alias‑usings platzieren; using‑Direktiven am Datei‑Anfang (vor namespace).
- CIT2403: Empfohlene Memberreihenfolge in Typen: Fields/Constants → Constructors/Finalizer → Events → Properties → Indexers → Methods.

## Unit Testing (CIT2500)

- CIT2500: Tests nach dem Muster Name_Method_Scenario_ExpectedResult benennen (was, scenario, expected).
- CIT2501: Tests in Arrange–Act–Assert strukturieren; Phasen klar trennen.
- CIT2502: Unit Tests schnell, unabhängig, reproduzierbar und selbst‑prüfend halten; keine Abhängigkeit zu externen Systemen (DB/FS/Network).
- CIT2503: Infrastrukturabhängige Prüfungen als Integrationstests separat auslagern.
- CIT2504: Keine umfangreiche Logik in Tests; Hilfsfunktionen für Setup/Teardown verwenden; magische Strings vermeiden.
- CIT2505: Tests so isoliert schreiben, dass Fehler klar auf die getestete Logik zurückgeführt werden können.

## LINQ & Abfragen (CIT2600)

- CIT2600: LINQ‑Abfragen explizit materialisieren (ToList/ToArray) bevor Ergebnisse zurückgegeben oder mehrfach enumerated werden.
- CIT2601: Bei Abfragen gegen persistence‑Layer asynchrone Endpunkte (z. B. ToListAsync) verwenden.
- CIT2602: Bei Projektionen auf Entitäten Vorsicht mit Objekt-Identity (neue Instanzen bei jeder Enumeration vermeiden).

## Sonstiges / Best Practices (CIT2700)

- CIT2700: Methoden, die mehrere verantwortliche Aufgaben erledigen, in mehrere Methoden aufteilen — ein PR sollte ein Anliegen adressieren.
- CIT2701: Optional-Parameter nur verwenden, wenn Überladungen dadurch sinnvoll ersetzt werden können; vollständigste Überladung intern aufrufen.
- CIT2703: Bei switch immer einen default-Block vorsehen; bei unerreichbaren Fällen eine InvalidOperationException werfen oder begründen.
