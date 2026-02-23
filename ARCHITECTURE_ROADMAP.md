# KieAIKit Compatibility-First Roadmap

This document defines how to evolve KieAIKit into a full-featured third-party Swift SPM toolkit for KIE without breaking existing integrations.

## Goals

1. Keep current public API stable for existing apps.
2. Expand coverage across KIE Market, Common API, File Upload, and Webhook verification.
3. Improve reliability, observability, and testability.

## Compatibility Contract (1.x)

1. Keep `KieAIClient` and existing service entry points.
2. Do not remove current public types or method signatures.
3. Add features via new methods, new service namespaces, and optional parameters with defaults.
4. Use deprecation before removal for any future breaking transition.

## Target Architecture

1. `Client Layer`: `KieAIClient` remains the user-facing facade.
2. `Service Layer`: Image/Video/Audio/Upload plus new Chat/Common/Webhook services.
3. `Core Layer`: transport, request builder, response decoder, auth, retry, and logging policies.
4. `Model Layer`: typed model enum plus extensible string-based model identifiers for fast KIE updates.

## Phased Plan

## Phase 1 (Immediate, Non-Breaking)

1. Safety fixes:
   - Eliminate force-casts in generic wait methods.
   - Normalize error mapping for KIE-specific response codes.
2. Consistency fixes:
   - Align examples with current enum/model names.
   - Ensure documented execution mode matches implementation behavior.
3. Infrastructure:
   - Add integration test harness with mock transport and deterministic polling tests.

## Phase 2 (Feature Expansion, Non-Breaking)

1. Add `CommonService`:
   - Query credits/balance endpoints.
   - Resolve download URL endpoints.
2. Add `WebhookVerifier`:
   - Signature verification utility for callback handling.
3. Expand model support:
   - Add missing high-value market models.
   - Provide custom string model entry for unlisted models.

## Phase 3 (Operational Quality)

1. Unified logger abstraction with configurable redaction.
2. Retry/backoff policy with status-code aware behavior.
3. Better task orchestration:
   - Optional callback-first workflows.
   - Background-safe polling helpers.

## Optional 2.0 Preparation (Future)

1. Introduce protocol-driven service interfaces for easier mocking.
2. Separate public API package and internal core package if needed.
3. Keep migration guide and compatibility shims for 1.x users.

## Acceptance Criteria

1. Existing 1.x app code compiles without modification.
2. New endpoints are accessible through additive APIs only.
3. SDK error messages are actionable and map cleanly to KIE semantics.
4. Example project and README snippets match real API names and behavior.

