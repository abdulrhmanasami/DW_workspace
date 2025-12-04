// Auth Shims Library
// Created by: CEN-AUTH001 Implementation
// Purpose: Unified exports for authentication domain models and contracts
// Last updated: 2025-12-04 (Track D - Ticket #233: Identity shim interface)

// Core authentication models and enums
export 'src/auth_models.dart';

// MFA/2FA models and contracts (CENT-004)
export 'src/mfa_models.dart';

// Identity models for session management (Track D - Ticket #233)
export 'src/identity_models.dart';

// Identity shim interface (Track D - Ticket #233)
export 'src/identity_shim.dart';

// Service interfaces
export 'src/auth_service.dart';
