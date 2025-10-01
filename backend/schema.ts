import { z } from 'zod';

// ============================================
// USERS SCHEMAS
// ============================================

// Main entity schema
export const userSchema = z.object({
  user_id: z.string(),
  email: z.string(),
  password_hash: z.string(),
  full_name: z.string(),
  phone_number: z.string().nullable(),
  role: z.string(),
  organization_id: z.string().nullable(),
  organization_role: z.string().nullable(),
  verification_status: z.string().nullable(),
  verification_notes: z.string().nullable(),
  verified_at: z.coerce.date().nullable(),
  verified_by: z.string().nullable(),
  primary_address: z.string().nullable(),
  city: z.string().nullable(),
  state: z.string().nullable(),
  postal_code: z.string().nullable(),
  country: z.string().nullable(),
  profile_photo_url: z.string().nullable(),
  is_active: z.boolean(),
  is_suspended: z.boolean(),
  suspension_reason: z.string().nullable(),
  last_login_at: z.coerce.date().nullable(),
  created_at: z.coerce.date(),
  updated_at: z.coerce.date()
});

// Create user input schema
export const createUserInputSchema = z.object({
  email: z.string().email().min(1).max(255),
  password: z.string().min(8).max(100),
  full_name: z.string().min(1).max(255),
  phone_number: z.string().max(50).nullable(),
  role: z.enum(['admin', 'buyer', 'vendor']),
  organization_id: z.string().nullable(),
  organization_role: z.string().max(100).nullable(),
  primary_address: z.string().max(500).nullable(),
  city: z.string().max(100).nullable(),
  state: z.string().max(100).nullable(),
  postal_code: z.string().max(20).nullable(),
  country: z.string().max(100).nullable(),
  profile_photo_url: z.string().url().nullable()
});

// Update user input schema
export const updateUserInputSchema = z.object({
  user_id: z.string(),
  email: z.string().email().min(1).max(255).optional(),
  full_name: z.string().min(1).max(255).optional(),
  phone_number: z.string().max(50).nullable().optional(),
  organization_id: z.string().nullable().optional(),
  organization_role: z.string().max(100).nullable().optional(),
  verification_status: z.string().max(50).nullable().optional(),
  verification_notes: z.string().nullable().optional(),
  primary_address: z.string().max(500).nullable().optional(),
  city: z.string().max(100).nullable().optional(),
  state: z.string().max(100).nullable().optional(),
  postal_code: z.string().max(20).nullable().optional(),
  country: z.string().max(100).nullable().optional(),
  profile_photo_url: z.string().url().nullable().optional(),
  is_active: z.boolean().optional(),
  is_suspended: z.boolean().optional(),
  suspension_reason: z.string().nullable().optional()
});

// Search/query user schema
export const searchUserInputSchema = z.object({
  query: z.string().optional(),
  role: z.enum(['admin', 'buyer', 'vendor']).optional(),
  organization_id: z.string().optional(),
  verification_status: z.string().optional(),
  is_active: z.boolean().optional(),
  is_suspended: z.boolean().optional(),
  limit: z.number().int().positive().default(10),
  offset: z.number().int().nonnegative().default(0),
  sort_by: z.enum(['created_at', 'full_name', 'email', 'last_login_at']).default('created_at'),
  sort_order: z.enum(['asc', 'desc']).default('desc')
});

export type User = z.infer<typeof userSchema>;
export type CreateUserInput = z.infer<typeof createUserInputSchema>;
export type UpdateUserInput = z.infer<typeof updateUserInputSchema>;
export type SearchUserInput = z.infer<typeof searchUserInputSchema>;

// ============================================
// ORGANIZATIONS SCHEMAS
// ============================================

export const organizationSchema = z.object({
  organization_id: z.string(),
  organization_name: z.string(),
  industry: z.string().nullable(),
  primary_address: z.string().nullable(),
  city: z.string().nullable(),
  state: z.string().nullable(),
  postal_code: z.string().nullable(),
  country: z.string().nullable(),
  logo_url: z.string().nullable(),
  website: z.string().nullable(),
  description: z.string().nullable(),
  created_by: z.string(),
  created_at: z.coerce.date(),
  updated_at: z.coerce.date()
});

export const createOrganizationInputSchema = z.object({
  organization_name: z.string().min(1).max(255),
  industry: z.string().max(100).nullable(),
  primary_address: z.string().max(500).nullable(),
  city: z.string().max(100).nullable(),
  state: z.string().max(100).nullable(),
  postal_code: z.string().max(20).nullable(),
  country: z.string().max(100).nullable(),
  logo_url: z.string().url().nullable(),
  website: z.string().url().nullable(),
  description: z.string().nullable(),
  created_by: z.string()
});

export const updateOrganizationInputSchema = z.object({
  organization_id: z.string(),
  organization_name: z.string().min(1).max(255).optional(),
  industry: z.string().max(100).nullable().optional(),
  primary_address: z.string().max(500).nullable().optional(),
  city: z.string().max(100).nullable().optional(),
  state: z.string().max(100).nullable().optional(),
  postal_code: z.string().max(20).nullable().optional(),
  country: z.string().max(100).nullable().optional(),
  logo_url: z.string().url().nullable().optional(),
  website: z.string().url().nullable().optional(),
  description: z.string().nullable().optional()
});

export const searchOrganizationInputSchema = z.object({
  query: z.string().optional(),
  industry: z.string().optional(),
  city: z.string().optional(),
  state: z.string().optional(),
  country: z.string().optional(),
  limit: z.number().int().positive().default(10),
  offset: z.number().int().nonnegative().default(0),
  sort_by: z.enum(['created_at', 'organization_name']).default('created_at'),
  sort_order: z.enum(['asc', 'desc']).default('desc')
});

export type Organization = z.infer<typeof organizationSchema>;
export type CreateOrganizationInput = z.infer<typeof createOrganizationInputSchema>;
export type UpdateOrganizationInput = z.infer<typeof updateOrganizationInputSchema>;
export type SearchOrganizationInput = z.infer<typeof searchOrganizationInputSchema>;

// ============================================
// ORGANIZATION INVITATIONS SCHEMAS
// ============================================

export const organizationInvitationSchema = z.object({
  invitation_id: z.string(),
  organization_id: z.string(),
  email: z.string(),
  role: z.string(),
  invited_by: z.string(),
  invitation_token: z.string(),
  status: z.string(),
  expires_at: z.coerce.date(),
  accepted_at: z.coerce.date().nullable(),
  created_at: z.coerce.date()
});

export const createOrganizationInvitationInputSchema = z.object({
  organization_id: z.string(),
  email: z.string().email(),
  role: z.string().min(1).max(100),
  invited_by: z.string(),
  expires_at: z.coerce.date()
});

export const updateOrganizationInvitationInputSchema = z.object({
  invitation_id: z.string(),
  status: z.enum(['pending', 'accepted', 'declined', 'expired']).optional(),
  accepted_at: z.coerce.date().nullable().optional()
});

export type OrganizationInvitation = z.infer<typeof organizationInvitationSchema>;
export type CreateOrganizationInvitationInput = z.infer<typeof createOrganizationInvitationInputSchema>;
export type UpdateOrganizationInvitationInput = z.infer<typeof updateOrganizationInvitationInputSchema>;

// ============================================
// AUTH SESSIONS SCHEMAS
// ============================================

export const authSessionSchema = z.object({
  session_id: z.string(),
  user_id: z.string(),
  auth_token: z.string(),
  device_name: z.string().nullable(),
  browser: z.string().nullable(),
  ip_address: z.string().nullable(),
  location: z.string().nullable(),
  expires_at: z.coerce.date(),
  last_active_at: z.coerce.date(),
  created_at: z.coerce.date()
});

export const createAuthSessionInputSchema = z.object({
  user_id: z.string(),
  device_name: z.string().max(255).nullable(),
  browser: z.string().max(255).nullable(),
  ip_address: z.string().ip().nullable(),
  location: z.string().max(255).nullable(),
  expires_at: z.coerce.date()
});

export type AuthSession = z.infer<typeof authSessionSchema>;
export type CreateAuthSessionInput = z.infer<typeof createAuthSessionInputSchema>;

// ============================================
// MAGIC LINKS SCHEMAS
// ============================================

export const magicLinkSchema = z.object({
  magic_link_id: z.string(),
  email: z.string(),
  token: z.string(),
  is_used: z.boolean(),
  expires_at: z.coerce.date(),
  used_at: z.coerce.date().nullable(),
  created_at: z.coerce.date()
});

export const createMagicLinkInputSchema = z.object({
  email: z.string().email(),
  expires_at: z.coerce.date()
});

export type MagicLink = z.infer<typeof magicLinkSchema>;
export type CreateMagicLinkInput = z.infer<typeof createMagicLinkInputSchema>;

// ============================================
// DELIVERY ADDRESSES SCHEMAS
// ============================================

export const deliveryAddressSchema = z.object({
  address_id: z.string(),
  user_id: z.string().nullable(),
  organization_id: z.string().nullable(),
  address_label: z.string(),
  contact_person_name: z.string(),
  contact_phone: z.string(),
  address_line_1: z.string(),
  address_line_2: z.string().nullable(),
  city: z.string(),
  state: z.string(),
  postal_code: z.string(),
  country: z.string(),
  delivery_instructions: z.string().nullable(),
  is_default: z.boolean(),
  created_at: z.coerce.date(),
  updated_at: z.coerce.date()
});

export const createDeliveryAddressInputSchema = z.object({
  user_id: z.string().nullable(),
  organization_id: z.string().nullable(),
  address_label: z.string().min(1).max(100),
  contact_person_name: z.string().min(1).max(255),
  contact_phone: z.string().min(1).max(50),
  address_line_1: z.string().min(1).max(500),
  address_line_2: z.string().max(500).nullable(),
  city: z.string().min(1).max(100),
  state: z.string().min(1).max(100),
  postal_code: z.string().min(1).max(20),
  country: z.string().min(1).max(100),
  delivery_instructions: z.string().nullable(),
  is_default: z.boolean().default(false)
});

export const updateDeliveryAddressInputSchema = z.object({
  address_id: z.string(),
  address_label: z.string().min(1).max(100).optional(),
  contact_person_name: z.string().min(1).max(255).optional(),
  contact_phone: z.string().min(1).max(50).optional(),
  address_line_1: z.string().min(1).max(500).optional(),
  address_line_2: z.string().max(500).nullable().optional(),
  city: z.string().min(1).max(100).optional(),
  state: z.string().min(1).max(100).optional(),
  postal_code: z.string().min(1).max(20).optional(),
  country: z.string().min(1).max(100).optional(),
  delivery_instructions: z.string().nullable().optional(),
  is_default: z.boolean().optional()
});

export type DeliveryAddress = z.infer<typeof deliveryAddressSchema>;
export type CreateDeliveryAddressInput = z.infer<typeof createDeliveryAddressInputSchema>;
export type UpdateDeliveryAddressInput = z.infer<typeof updateDeliveryAddressInputSchema>;

// ============================================
// CATEGORIES SCHEMAS
// ============================================

export const categorySchema = z.object({
  category_id: z.string(),
  category_name: z.string(),
  parent_category_id: z.string().nullable(),
  description: z.string().nullable(),
  icon_url: z.string().nullable(),
  is_active: z.boolean(),
  sort_order: z.number().nullable(),
  created_at: z.coerce.date(),
  updated_at: z.coerce.date()
});

export const createCategoryInputSchema = z.object({
  category_name: z.string().min(1).max(255),
  parent_category_id: z.string().nullable(),
  description: z.string().nullable(),
  icon_url: z.string().url().nullable(),
  is_active: z.boolean().default(true),
  sort_order: z.number().int().nullable()
});

export const updateCategoryInputSchema = z.object({
  category_id: z.string(),
  category_name: z.string().min(1).max(255).optional(),
  parent_category_id: z.string().nullable().optional(),
  description: z.string().nullable().optional(),
  icon_url: z.string().url().nullable().optional(),
  is_active: z.boolean().optional(),
  sort_order: z.number().int().nullable().optional()
});

export const searchCategoryInputSchema = z.object({
  query: z.string().optional(),
  parent_category_id: z.string().optional(),
  is_active: z.boolean().optional(),
  limit: z.number().int().positive().default(50),
  offset: z.number().int().nonnegative().default(0),
  sort_by: z.enum(['category_name', 'sort_order', 'created_at']).default('sort_order'),
  sort_order: z.enum(['asc', 'desc']).default('asc')
});

export type Category = z.infer<typeof categorySchema>;
export type CreateCategoryInput = z.infer<typeof createCategoryInputSchema>;
export type UpdateCategoryInput = z.infer<typeof updateCategoryInputSchema>;
export type SearchCategoryInput = z.infer<typeof searchCategoryInputSchema>;

// ============================================
// BRANDS SCHEMAS
// ============================================

export const brandSchema = z.object({
  brand_id: z.string(),
  brand_name: z.string(),
  logo_url: z.string().nullable(),
  website: z.string().nullable(),
  description: z.string().nullable(),
  is_active: z.boolean(),
  created_at: z.coerce.date(),
  updated_at: z.coerce.date()
});

export const createBrandInputSchema = z.object({
  brand_name: z.string().min(1).max(255),
  logo_url: z.string().url().nullable(),
  website: z.string().url().nullable(),
  description: z.string().nullable(),
  is_active: z.boolean().default(true)
});

export const updateBrandInputSchema = z.object({
  brand_id: z.string(),
  brand_name: z.string().min(1).max(255).optional(),
  logo_url: z.string().url().nullable().optional(),
  website: z.string().url().nullable().optional(),
  description: z.string().nullable().optional(),
  is_active: z.boolean().optional()
});

export const searchBrandInputSchema = z.object({
  query: z.string().optional(),
  is_active: z.boolean().optional(),
  limit: z.number().int().positive().default(50),
  offset: z.number().int().nonnegative().default(0),
  sort_by: z.enum(['brand_name', 'created_at']).default('brand_name'),
  sort_order: z.enum(['asc', 'desc']).default('asc')
});

export type Brand = z.infer<typeof brandSchema>;
export type CreateBrandInput = z.infer<typeof createBrandInputSchema>;
export type UpdateBrandInput = z.infer<typeof updateBrandInputSchema>;
export type SearchBrandInput = z.infer<typeof searchBrandInputSchema>;

// ============================================
// UNIT TYPES SCHEMAS
// ============================================

export const unitTypeSchema = z.object({
  unit_type_id: z.string(),
  unit_name: z.string(),
  unit_abbreviation: z.string().nullable(),
  is_active: z.boolean(),
  created_at: z.coerce.date()
});

export const createUnitTypeInputSchema = z.object({
  unit_name: z.string().min(1).max(100),
  unit_abbreviation: z.string().max(20).nullable(),
  is_active: z.boolean().default(true)
});

export const updateUnitTypeInputSchema = z.object({
  unit_type_id: z.string(),
  unit_name: z.string().min(1).max(100).optional(),
  unit_abbreviation: z.string().max(20).nullable().optional(),
  is_active: z.boolean().optional()
});

export type UnitType = z.infer<typeof unitTypeSchema>;
export type CreateUnitTypeInput = z.infer<typeof createUnitTypeInputSchema>;
export type UpdateUnitTypeInput = z.infer<typeof updateUnitTypeInputSchema>;

// ============================================
// CANONICAL PRODUCTS SCHEMAS
// ============================================

export const canonicalProductSchema = z.object({
  product_id: z.string(),
  product_name: z.string(),
  brand_id: z.string(),
  model: z.string(),
  category_id: z.string(),
  subcategory_id: z.string().nullable(),
  unit_type_id: z.string(),
  specifications: z.record(z.any()).nullable(),
  description: z.string().nullable(),
  status: z.string(),
  created_by: z.string(),
  created_at: z.coerce.date(),
  updated_at: z.coerce.date()
});

export const createCanonicalProductInputSchema = z.object({
  product_name: z.string().min(1).max(500),
  brand_id: z.string(),
  model: z.string().min(1).max(255),
  category_id: z.string(),
  subcategory_id: z.string().nullable(),
  unit_type_id: z.string(),
  specifications: z.record(z.any()).nullable(),
  description: z.string().nullable(),
  status: z.enum(['active', 'inactive', 'discontinued']).default('active'),
  created_by: z.string()
});

export const updateCanonicalProductInputSchema = z.object({
  product_id: z.string(),
  product_name: z.string().min(1).max(500).optional(),
  brand_id: z.string().optional(),
  model: z.string().min(1).max(255).optional(),
  category_id: z.string().optional(),
  subcategory_id: z.string().nullable().optional(),
  unit_type_id: z.string().optional(),
  specifications: z.record(z.any()).nullable().optional(),
  description: z.string().nullable().optional(),
  status: z.enum(['active', 'inactive', 'discontinued']).optional()
});

export const searchCanonicalProductInputSchema = z.object({
  query: z.string().optional(),
  brand_id: z.string().optional(),
  category_id: z.string().optional(),
  subcategory_id: z.string().optional(),
  status: z.enum(['active', 'inactive', 'discontinued']).optional(),
  limit: z.number().int().positive().default(20),
  offset: z.number().int().nonnegative().default(0),
  sort_by: z.enum(['product_name', 'created_at', 'brand_id']).default('created_at'),
  sort_order: z.enum(['asc', 'desc']).default('desc')
});

export type CanonicalProduct = z.infer<typeof canonicalProductSchema>;
export type CreateCanonicalProductInput = z.infer<typeof createCanonicalProductInputSchema>;
export type UpdateCanonicalProductInput = z.infer<typeof updateCanonicalProductInputSchema>;
export type SearchCanonicalProductInput = z.infer<typeof searchCanonicalProductInputSchema>;

// ============================================
// PRODUCT IMAGES SCHEMAS
// ============================================

export const productImageSchema = z.object({
  image_id: z.string(),
  product_id: z.string(),
  image_url: z.string(),
  is_primary: z.boolean(),
  sort_order: z.number().nullable(),
  uploaded_at: z.coerce.date()
});

export const createProductImageInputSchema = z.object({
  product_id: z.string(),
  image_url: z.string().url(),
  is_primary: z.boolean().default(false),
  sort_order: z.number().int().nullable()
});

export const updateProductImageInputSchema = z.object({
  image_id: z.string(),
  is_primary: z.boolean().optional(),
  sort_order: z.number().int().nullable().optional()
});

export type ProductImage = z.infer<typeof productImageSchema>;
export type CreateProductImageInput = z.infer<typeof createProductImageInputSchema>;
export type UpdateProductImageInput = z.infer<typeof updateProductImageInputSchema>;

// ============================================
// VENDOR PROFILES SCHEMAS
// ============================================

export const vendorProfileSchema = z.object({
  vendor_id: z.string(),
  business_name: z.string(),
  business_type: z.string().nullable(),
  business_registration_number: z.string().nullable(),
  tax_id: z.string().nullable(),
  business_address: z.string().nullable(),
  city: z.string().nullable(),
  state: z.string().nullable(),
  postal_code: z.string().nullable(),
  country: z.string().nullable(),
  description: z.string().nullable(),
  logo_url: z.string().nullable(),
  cover_image_url: z.string().nullable(),
  website: z.string().nullable(),
  operating_hours: z.record(z.string()).nullable(),
  primary_color: z.string().nullable(),
  average_rating: z.number().nullable(),
  total_reviews: z.number(),
  total_orders: z.number(),
  response_time_hours: z.number().nullable(),
  fulfillment_rate: z.number().nullable(),
  created_at: z.coerce.date(),
  updated_at: z.coerce.date()
});

export const createVendorProfileInputSchema = z.object({
  vendor_id: z.string(),
  business_name: z.string().min(1).max(255),
  business_type: z.string().max(100).nullable(),
  business_registration_number: z.string().max(100).nullable(),
  tax_id: z.string().max(100).nullable(),
  business_address: z.string().max(500).nullable(),
  city: z.string().max(100).nullable(),
  state: z.string().max(100).nullable(),
  postal_code: z.string().max(20).nullable(),
  country: z.string().max(100).nullable(),
  description: z.string().nullable(),
  logo_url: z.string().url().nullable(),
  cover_image_url: z.string().url().nullable(),
  website: z.string().url().nullable(),
  operating_hours: z.record(z.string()).nullable(),
  primary_color: z.string().regex(/^#[0-9A-Fa-f]{6}$/).nullable()
});

export const updateVendorProfileInputSchema = z.object({
  vendor_id: z.string(),
  business_name: z.string().min(1).max(255).optional(),
  business_type: z.string().max(100).nullable().optional(),
  business_registration_number: z.string().max(100).nullable().optional(),
  tax_id: z.string().max(100).nullable().optional(),
  business_address: z.string().max(500).nullable().optional(),
  city: z.string().max(100).nullable().optional(),
  state: z.string().max(100).nullable().optional(),
  postal_code: z.string().max(20).nullable().optional(),
  country: z.string().max(100).nullable().optional(),
  description: z.string().nullable().optional(),
  logo_url: z.string().url().nullable().optional(),
  cover_image_url: z.string().url().nullable().optional(),
  website: z.string().url().nullable().optional(),
  operating_hours: z.record(z.string()).nullable().optional(),
  primary_color: z.string().regex(/^#[0-9A-Fa-f]{6}$/).nullable().optional()
});

export const searchVendorProfileInputSchema = z.object({
  query: z.string().optional(),
  city: z.string().optional(),
  state: z.string().optional(),
  business_type: z.string().optional(),
  min_rating: z.number().min(0).max(5).optional(),
  limit: z.number().int().positive().default(20),
  offset: z.number().int().nonnegative().default(0),
  sort_by: z.enum(['business_name', 'average_rating', 'total_orders', 'created_at']).default('average_rating'),
  sort_order: z.enum(['asc', 'desc']).default('desc')
});

export type VendorProfile = z.infer<typeof vendorProfileSchema>;
export type CreateVendorProfileInput = z.infer<typeof createVendorProfileInputSchema>;
export type UpdateVendorProfileInput = z.infer<typeof updateVendorProfileInputSchema>;
export type SearchVendorProfileInput = z.infer<typeof searchVendorProfileInputSchema>;

// ============================================
// VENDOR OFFERS SCHEMAS
// ============================================

export const vendorOfferSchema = z.object({
  offer_id: z.string(),
  vendor_id: z.string(),
  product_id: z.string(),
  vendor_sku: z.string().nullable(),
  price: z.number(),
  currency: z.string(),
  stock_quantity: z.number(),
  min_order_quantity: z.number(),
  max_order_quantity: z.number().nullable(),
  lead_time_days: z.number(),
  status: z.string(),
  internal_notes: z.string().nullable(),
  created_at: z.coerce.date(),
  updated_at: z.coerce.date()
});

export const createVendorOfferInputSchema = z.object({
  vendor_id: z.string(),
  product_id: z.string(),
  vendor_sku: z.string().max(100).nullable(),
  price: z.number().positive(),
  currency: z.string().length(3).default('USD'),
  stock_quantity: z.number().int().nonnegative(),
  min_order_quantity: z.number().int().positive(),
  max_order_quantity: z.number().int().positive().nullable(),
  lead_time_days: z.number().int().nonnegative(),
  status: z.enum(['active', 'inactive', 'out_of_stock']).default('active'),
  internal_notes: z.string().nullable()
});

export const updateVendorOfferInputSchema = z.object({
  offer_id: z.string(),
  vendor_sku: z.string().max(100).nullable().optional(),
  price: z.number().positive().optional(),
  currency: z.string().length(3).optional(),
  stock_quantity: z.number().int().nonnegative().optional(),
  min_order_quantity: z.number().int().positive().optional(),
  max_order_quantity: z.number().int().positive().nullable().optional(),
  lead_time_days: z.number().int().nonnegative().optional(),
  status: z.enum(['active', 'inactive', 'out_of_stock']).optional(),
  internal_notes: z.string().nullable().optional()
});

export const searchVendorOfferInputSchema = z.object({
  vendor_id: z.string().optional(),
  product_id: z.string().optional(),
  status: z.enum(['active', 'inactive', 'out_of_stock']).optional(),
  min_price: z.number().positive().optional(),
  max_price: z.number().positive().optional(),
  in_stock_only: z.boolean().optional(),
  limit: z.number().int().positive().default(20),
  offset: z.number().int().nonnegative().default(0),
  sort_by: z.enum(['price', 'created_at', 'stock_quantity']).default('price'),
  sort_order: z.enum(['asc', 'desc']).default('asc')
});

export type VendorOffer = z.infer<typeof vendorOfferSchema>;
export type CreateVendorOfferInput = z.infer<typeof createVendorOfferInputSchema>;
export type UpdateVendorOfferInput = z.infer<typeof updateVendorOfferInputSchema>;
export type SearchVendorOfferInput = z.infer<typeof searchVendorOfferInputSchema>;

// ============================================
// RFQs SCHEMAS
// ============================================

export const rfqSchema = z.object({
  rfq_id: z.string(),
  rfq_number: z.string(),
  buyer_id: z.string(),
  organization_id: z.string().nullable(),
  product_id: z.string(),
  quantity: z.number(),
  delivery_address_id: z.string(),
  preferred_delivery_date: z.coerce.date().nullable(),
  notes: z.string().nullable(),
  status: z.string(),
  expires_at: z.coerce.date().nullable(),
  closed_reason: z.string().nullable(),
  closed_at: z.coerce.date().nullable(),
  created_at: z.coerce.date(),
  updated_at: z.coerce.date()
});

export const createRfqInputSchema = z.object({
  buyer_id: z.string(),
  organization_id: z.string().nullable(),
  product_id: z.string(),
  quantity: z.number().int().positive(),
  delivery_address_id: z.string(),
  preferred_delivery_date: z.coerce.date().nullable(),
  notes: z.string().max(2000).nullable(),
  status: z.enum(['draft', 'active', 'closed', 'cancelled']).default('draft'),
  expires_at: z.coerce.date().nullable()
});

export const updateRfqInputSchema = z.object({
  rfq_id: z.string(),
  quantity: z.number().int().positive().optional(),
  delivery_address_id: z.string().optional(),
  preferred_delivery_date: z.coerce.date().nullable().optional(),
  notes: z.string().max(2000).nullable().optional(),
  status: z.enum(['draft', 'active', 'closed', 'cancelled']).optional(),
  expires_at: z.coerce.date().nullable().optional(),
  closed_reason: z.string().nullable().optional()
});

export const searchRfqInputSchema = z.object({
  buyer_id: z.string().optional(),
  organization_id: z.string().optional(),
  product_id: z.string().optional(),
  status: z.enum(['draft', 'active', 'closed', 'cancelled']).optional(),
  from_date: z.coerce.date().optional(),
  to_date: z.coerce.date().optional(),
  limit: z.number().int().positive().default(20),
  offset: z.number().int().nonnegative().default(0),
  sort_by: z.enum(['created_at', 'expires_at', 'rfq_number']).default('created_at'),
  sort_order: z.enum(['asc', 'desc']).default('desc')
});

export type Rfq = z.infer<typeof rfqSchema>;
export type CreateRfqInput = z.infer<typeof createRfqInputSchema>;
export type UpdateRfqInput = z.infer<typeof updateRfqInputSchema>;
export type SearchRfqInput = z.infer<typeof searchRfqInputSchema>;

// ============================================
// QUOTES SCHEMAS
// ============================================

export const quoteSchema = z.object({
  quote_id: z.string(),
  rfq_id: z.string(),
  vendor_id: z.string(),
  price_per_unit: z.number(),
  currency: z.string(),
  quantity_available: z.number(),
  min_order_quantity: z.number().nullable(),
  max_order_quantity: z.number().nullable(),
  delivery_fee: z.number().nullable(),
  lead_time_days: z.number(),
  payment_terms: z.string(),
  valid_until: z.coerce.date(),
  notes: z.string().nullable(),
  status: z.string(),
  accepted_at: z.coerce.date().nullable(),
  created_at: z.coerce.date(),
  updated_at: z.coerce.date()
});

export const createQuoteInputSchema = z.object({
  rfq_id: z.string(),
  vendor_id: z.string(),
  price_per_unit: z.number().positive(),
  currency: z.string().length(3).default('USD'),
  quantity_available: z.number().int().positive(),
  min_order_quantity: z.number().int().positive().nullable(),
  max_order_quantity: z.number().int().positive().nullable(),
  delivery_fee: z.number().nonnegative().nullable(),
  lead_time_days: z.number().int().nonnegative(),
  payment_terms: z.enum(['cod', 'net_30', 'net_60', 'prepaid']).default('cod'),
  valid_until: z.coerce.date(),
  notes: z.string().max(2000).nullable()
});

export const updateQuoteInputSchema = z.object({
  quote_id: z.string(),
  price_per_unit: z.number().positive().optional(),
  quantity_available: z.number().int().positive().optional(),
  min_order_quantity: z.number().int().positive().nullable().optional(),
  max_order_quantity: z.number().int().positive().nullable().optional(),
  delivery_fee: z.number().nonnegative().nullable().optional(),
  lead_time_days: z.number().int().nonnegative().optional(),
  payment_terms: z.enum(['cod', 'net_30', 'net_60', 'prepaid']).optional(),
  valid_until: z.coerce.date().optional(),
  notes: z.string().max(2000).nullable().optional(),
  status: z.enum(['submitted', 'accepted', 'declined', 'expired']).optional()
});

export const searchQuoteInputSchema = z.object({
  rfq_id: z.string().optional(),
  vendor_id: z.string().optional(),
  status: z.enum(['submitted', 'accepted', 'declined', 'expired']).optional(),
  min_price: z.number().positive().optional(),
  max_price: z.number().positive().optional(),
  limit: z.number().int().positive().default(20),
  offset: z.number().int().nonnegative().default(0),
  sort_by: z.enum(['created_at', 'price_per_unit', 'valid_until']).default('created_at'),
  sort_order: z.enum(['asc', 'desc']).default('desc')
});

export type Quote = z.infer<typeof quoteSchema>;
export type CreateQuoteInput = z.infer<typeof createQuoteInputSchema>;
export type UpdateQuoteInput = z.infer<typeof updateQuoteInputSchema>;
export type SearchQuoteInput = z.infer<typeof searchQuoteInputSchema>;

// ============================================
// ORDERS SCHEMAS
// ============================================

export const orderSchema = z.object({
  order_id: z.string(),
  order_number: z.string(),
  rfq_id: z.string(),
  quote_id: z.string(),
  buyer_id: z.string(),
  vendor_id: z.string(),
  organization_id: z.string().nullable(),
  product_id: z.string(),
  quantity: z.number(),
  unit_price: z.number(),
  currency: z.string(),
  subtotal: z.number(),
  delivery_fee: z.number().nullable(),
  total_amount: z.number(),
  delivery_address_id: z.string(),
  expected_delivery_date: z.coerce.date().nullable(),
  status: z.string(),
  payment_method: z.string(),
  vendor_declined_reason: z.string().nullable(),
  cancelled_by: z.string().nullable(),
  cancellation_reason: z.string().nullable(),
  cancelled_at: z.coerce.date().nullable(),
  created_at: z.coerce.date(),
  updated_at: z.coerce.date()
});

export const createOrderInputSchema = z.object({
  rfq_id: z.string(),
  quote_id: z.string(),
  buyer_id: z.string(),
  vendor_id: z.string(),
  organization_id: z.string().nullable(),
  product_id: z.string(),
  quantity: z.number().int().positive(),
  unit_price: z.number().positive(),
  currency: z.string().length(3).default('USD'),
  delivery_fee: z.number().nonnegative().nullable(),
  delivery_address_id: z.string(),
  expected_delivery_date: z.coerce.date().nullable(),
  payment_method: z.enum(['cod', 'prepaid', 'credit']).default('cod')
});

export const updateOrderInputSchema = z.object({
  order_id: z.string(),
  status: z.enum([
    'pending_vendor_confirmation',
    'confirmed',
    'preparing',
    'dispatched',
    'in_transit',
    'delivered',
    'cancelled',
    'vendor_declined'
  ]).optional(),
  expected_delivery_date: z.coerce.date().nullable().optional(),
  vendor_declined_reason: z.string().nullable().optional(),
  cancellation_reason: z.string().nullable().optional()
});

export const searchOrderInputSchema = z.object({
  buyer_id: z.string().optional(),
  vendor_id: z.string().optional(),
  organization_id: z.string().optional(),
  status: z.string().optional(),
  from_date: z.coerce.date().optional(),
  to_date: z.coerce.date().optional(),
  min_amount: z.number().positive().optional(),
  max_amount: z.number().positive().optional(),
  limit: z.number().int().positive().default(20),
  offset: z.number().int().nonnegative().default(0),
  sort_by: z.enum(['created_at', 'total_amount', 'order_number', 'expected_delivery_date']).default('created_at'),
  sort_order: z.enum(['asc', 'desc']).default('desc')
});

export type Order = z.infer<typeof orderSchema>;
export type CreateOrderInput = z.infer<typeof createOrderInputSchema>;
export type UpdateOrderInput = z.infer<typeof updateOrderInputSchema>;
export type SearchOrderInput = z.infer<typeof searchOrderInputSchema>;

// ============================================
// REVIEWS SCHEMAS
// ============================================

export const reviewSchema = z.object({
  review_id: z.string(),
  order_id: z.string(),
  buyer_id: z.string(),
  vendor_id: z.string(),
  overall_rating: z.number(),
  product_quality_rating: z.number().nullable(),
  delivery_rating: z.number().nullable(),
  communication_rating: z.number().nullable(),
  pricing_rating: z.number().nullable(),
  review_text: z.string().nullable(),
  is_anonymous: z.boolean(),
  helpful_count: z.number(),
  is_verified_purchase: z.boolean(),
  vendor_response: z.string().nullable(),
  vendor_response_at: z.coerce.date().nullable(),
  status: z.string(),
  hidden_reason: z.string().nullable(),
  hidden_by: z.string().nullable(),
  hidden_at: z.coerce.date().nullable(),
  created_at: z.coerce.date(),
  updated_at: z.coerce.date()
});

export const createReviewInputSchema = z.object({
  order_id: z.string(),
  buyer_id: z.string(),
  vendor_id: z.string(),
  overall_rating: z.number().min(1).max(5),
  product_quality_rating: z.number().min(1).max(5).nullable(),
  delivery_rating: z.number().min(1).max(5).nullable(),
  communication_rating: z.number().min(1).max(5).nullable(),
  pricing_rating: z.number().min(1).max(5).nullable(),
  review_text: z.string().max(2000).nullable(),
  is_anonymous: z.boolean().default(false)
});

export const updateReviewInputSchema = z.object({
  review_id: z.string(),
  review_text: z.string().max(2000).nullable().optional(),
  vendor_response: z.string().max(2000).nullable().optional(),
  status: z.enum(['published', 'hidden', 'flagged']).optional(),
  hidden_reason: z.string().nullable().optional()
});

export const searchReviewInputSchema = z.object({
  vendor_id: z.string().optional(),
  buyer_id: z.string().optional(),
  product_id: z.string().optional(),
  min_rating: z.number().min(1).max(5).optional(),
  status: z.enum(['published', 'hidden', 'flagged']).optional(),
  is_verified_purchase: z.boolean().optional(),
  limit: z.number().int().positive().default(20),
  offset: z.number().int().nonnegative().default(0),
  sort_by: z.enum(['created_at', 'overall_rating', 'helpful_count']).default('created_at'),
  sort_order: z.enum(['asc', 'desc']).default('desc')
});

export type Review = z.infer<typeof reviewSchema>;
export type CreateReviewInput = z.infer<typeof createReviewInputSchema>;
export type UpdateReviewInput = z.infer<typeof updateReviewInputSchema>;
export type SearchReviewInput = z.infer<typeof searchReviewInputSchema>;

// ============================================
// NOTIFICATIONS SCHEMAS
// ============================================

export const notificationSchema = z.object({
  notification_id: z.string(),
  user_id: z.string(),
  notification_type: z.string(),
  category: z.string(),
  title: z.string(),
  message: z.string(),
  link_url: z.string().nullable(),
  entity_type: z.string().nullable(),
  entity_id: z.string().nullable(),
  is_read: z.boolean(),
  read_at: z.coerce.date().nullable(),
  is_archived: z.boolean(),
  archived_at: z.coerce.date().nullable(),
  created_at: z.coerce.date()
});

export const createNotificationInputSchema = z.object({
  user_id: z.string(),
  notification_type: z.string().max(100),
  category: z.string().max(100),
  title: z.string().min(1).max(255),
  message: z.string().min(1).max(1000),
  link_url: z.string().url().nullable(),
  entity_type: z.string().max(100).nullable(),
  entity_id: z.string().nullable()
});

export const updateNotificationInputSchema = z.object({
  notification_id: z.string(),
  is_read: z.boolean().optional(),
  is_archived: z.boolean().optional()
});

export const searchNotificationInputSchema = z.object({
  user_id: z.string(),
  category: z.string().optional(),
  is_read: z.boolean().optional(),
  is_archived: z.boolean().optional(),
  from_date: z.coerce.date().optional(),
  limit: z.number().int().positive().default(50),
  offset: z.number().int().nonnegative().default(0),
  sort_by: z.enum(['created_at']).default('created_at'),
  sort_order: z.enum(['asc', 'desc']).default('desc')
});

export type Notification = z.infer<typeof notificationSchema>;
export type CreateNotificationInput = z.infer<typeof createNotificationInputSchema>;
export type UpdateNotificationInput = z.infer<typeof updateNotificationInputSchema>;
export type SearchNotificationInput = z.infer<typeof searchNotificationInputSchema>;

// ============================================
// DISPUTES SCHEMAS
// ============================================

export const disputeSchema = z.object({
  dispute_id: z.string(),
  order_id: z.string(),
  raised_by: z.string(),
  issue_type: z.string(),
  description: z.string(),
  preferred_resolution: z.string().nullable(),
  status: z.string(),
  assigned_to: z.string().nullable(),
  resolution_decision: z.string().nullable(),
  resolution_notes: z.string().nullable(),
  resolution_action: z.string().nullable(),
  resolved_by: z.string().nullable(),
  resolved_at: z.coerce.date().nullable(),
  closed_at: z.coerce.date().nullable(),
  created_at: z.coerce.date(),
  updated_at: z.coerce.date()
});

export const createDisputeInputSchema = z.object({
  order_id: z.string(),
  raised_by: z.string(),
  issue_type: z.enum(['quality_issue', 'delivery_issue', 'pricing_issue', 'other']),
  description: z.string().min(10).max(2000),
  preferred_resolution: z.string().max(1000).nullable()
});

export const updateDisputeInputSchema = z.object({
  dispute_id: z.string(),
  status: z.enum(['open', 'investigating', 'resolved', 'closed']).optional(),
  assigned_to: z.string().nullable().optional(),
  resolution_decision: z.string().nullable().optional(),
  resolution_notes: z.string().nullable().optional(),
  resolution_action: z.string().nullable().optional()
});

export const searchDisputeInputSchema = z.object({
  order_id: z.string().optional(),
  raised_by: z.string().optional(),
  issue_type: z.string().optional(),
  status: z.enum(['open', 'investigating', 'resolved', 'closed']).optional(),
  assigned_to: z.string().optional(),
  limit: z.number().int().positive().default(20),
  offset: z.number().int().nonnegative().default(0),
  sort_by: z.enum(['created_at', 'updated_at']).default('created_at'),
  sort_order: z.enum(['asc', 'desc']).default('desc')
});

export type Dispute = z.infer<typeof disputeSchema>;
export type CreateDisputeInput = z.infer<typeof createDisputeInputSchema>;
export type UpdateDisputeInput = z.infer<typeof updateDisputeInputSchema>;
export type SearchDisputeInput = z.infer<typeof searchDisputeInputSchema>;

// ============================================
// CSV IMPORTS SCHEMAS
// ============================================

export const csvImportSchema = z.object({
  import_id: z.string(),
  vendor_id: z.string(),
  file_name: z.string(),
  file_url: z.string().nullable(),
  total_rows: z.number(),
  successful_rows: z.number(),
  failed_rows: z.number(),
  pending_review_rows: z.number(),
  status: z.string(),
  error_report_url: z.string().nullable(),
  column_mapping: z.record(z.string()).nullable(),
  created_at: z.coerce.date(),
  completed_at: z.coerce.date().nullable()
});

export const createCsvImportInputSchema = z.object({
  vendor_id: z.string(),
  file_name: z.string().min(1).max(255),
  file_url: z.string().url().nullable(),
  total_rows: z.number().int().nonnegative(),
  column_mapping: z.record(z.string()).nullable()
});

export const updateCsvImportInputSchema = z.object({
  import_id: z.string(),
  successful_rows: z.number().int().nonnegative().optional(),
  failed_rows: z.number().int().nonnegative().optional(),
  pending_review_rows: z.number().int().nonnegative().optional(),
  status: z.enum(['processing', 'completed', 'failed', 'partial']).optional(),
  error_report_url: z.string().url().nullable().optional()
});

export type CsvImport = z.infer<typeof csvImportSchema>;
export type CreateCsvImportInput = z.infer<typeof createCsvImportInputSchema>;
export type UpdateCsvImportInput = z.infer<typeof updateCsvImportInputSchema>;

// ============================================
// AUDIT LOGS SCHEMAS
// ============================================

export const auditLogSchema = z.object({
  log_id: z.string(),
  user_id: z.string().nullable(),
  action_type: z.string(),
  entity_type: z.string().nullable(),
  entity_id: z.string().nullable(),
  old_value: z.record(z.any()).nullable(),
  new_value: z.record(z.any()).nullable(),
  ip_address: z.string().nullable(),
  user_agent: z.string().nullable(),
  details: z.record(z.any()).nullable(),
  created_at: z.coerce.date()
});

export const createAuditLogInputSchema = z.object({
  user_id: z.string().nullable(),
  action_type: z.string().min(1).max(100),
  entity_type: z.string().max(100).nullable(),
  entity_id: z.string().nullable(),
  old_value: z.record(z.any()).nullable(),
  new_value: z.record(z.any()).nullable(),
  ip_address: z.string().ip().nullable(),
  user_agent: z.string().max(500).nullable(),
  details: z.record(z.any()).nullable()
});

export const searchAuditLogInputSchema = z.object({
  user_id: z.string().optional(),
  action_type: z.string().optional(),
  entity_type: z.string().optional(),
  entity_id: z.string().optional(),
  from_date: z.coerce.date().optional(),
  to_date: z.coerce.date().optional(),
  limit: z.number().int().positive().default(50),
  offset: z.number().int().nonnegative().default(0),
  sort_by: z.enum(['created_at']).default('created_at'),
  sort_order: z.enum(['asc', 'desc']).default('desc')
});

export type AuditLog = z.infer<typeof auditLogSchema>;
export type CreateAuditLogInput = z.infer<typeof createAuditLogInputSchema>;
export type SearchAuditLogInput = z.infer<typeof searchAuditLogInputSchema>;

// ============================================
// WEBHOOKS SCHEMAS
// ============================================

export const webhookSchema = z.object({
  webhook_id: z.string(),
  vendor_id: z.string(),
  endpoint_url: z.string(),
  secret_key: z.string(),
  events: z.array(z.string()),
  is_active: z.boolean(),
  created_at: z.coerce.date(),
  updated_at: z.coerce.date()
});

export const createWebhookInputSchema = z.object({
  vendor_id: z.string(),
  endpoint_url: z.string().url(),
  events: z.array(z.string()).min(1),
  is_active: z.boolean().default(true)
});

export const updateWebhookInputSchema = z.object({
  webhook_id: z.string(),
  endpoint_url: z.string().url().optional(),
  events: z.array(z.string()).min(1).optional(),
  is_active: z.boolean().optional()
});

export type Webhook = z.infer<typeof webhookSchema>;
export type CreateWebhookInput = z.infer<typeof createWebhookInputSchema>;
export type UpdateWebhookInput = z.infer<typeof updateWebhookInputSchema>;

// ============================================
// CURRENCIES SCHEMAS
// ============================================

export const currencySchema = z.object({
  currency_code: z.string(),
  currency_name: z.string(),
  symbol: z.string(),
  exchange_rate_to_base: z.number(),
  is_active: z.boolean(),
  last_updated: z.coerce.date()
});

export const createCurrencyInputSchema = z.object({
  currency_code: z.string().length(3).toUpperCase(),
  currency_name: z.string().min(1).max(100),
  symbol: z.string().min(1).max(10),
  exchange_rate_to_base: z.number().positive(),
  is_active: z.boolean().default(true)
});

export const updateCurrencyInputSchema = z.object({
  currency_code: z.string().length(3).toUpperCase(),
  exchange_rate_to_base: z.number().positive().optional(),
  is_active: z.boolean().optional()
});

export type Currency = z.infer<typeof currencySchema>;
export type CreateCurrencyInput = z.infer<typeof createCurrencyInputSchema>;
export type UpdateCurrencyInput = z.infer<typeof updateCurrencyInputSchema>;

// ============================================
// CITIES SCHEMAS
// ============================================

export const citySchema = z.object({
  city_id: z.string(),
  city_name: z.string(),
  state: z.string(),
  country: z.string(),
  latitude: z.number().nullable(),
  longitude: z.number().nullable(),
  is_active: z.boolean()
});

export const createCityInputSchema = z.object({
  city_name: z.string().min(1).max(100),
  state: z.string().min(1).max(100),
  country: z.string().min(1).max(100),
  latitude: z.number().min(-90).max(90).nullable(),
  longitude: z.number().min(-180).max(180).nullable(),
  is_active: z.boolean().default(true)
});

export const updateCityInputSchema = z.object({
  city_id: z.string(),
  latitude: z.number().min(-90).max(90).nullable().optional(),
  longitude: z.number().min(-180).max(180).nullable().optional(),
  is_active: z.boolean().optional()
});

export const searchCityInputSchema = z.object({
  query: z.string().optional(),
  state: z.string().optional(),
  country: z.string().optional(),
  is_active: z.boolean().optional(),
  limit: z.number().int().positive().default(50),
  offset: z.number().int().nonnegative().default(0),
  sort_by: z.enum(['city_name', 'state']).default('city_name'),
  sort_order: z.enum(['asc', 'desc']).default('asc')
});

export type City = z.infer<typeof citySchema>;
export type CreateCityInput = z.infer<typeof createCityInputSchema>;
export type UpdateCityInput = z.infer<typeof updateCityInputSchema>;
export type SearchCityInput = z.infer<typeof searchCityInputSchema>;

// ============================================
// SYSTEM SETTINGS SCHEMAS
// ============================================

export const systemSettingSchema = z.object({
  setting_key: z.string(),
  setting_value: z.record(z.any()),
  setting_type: z.string(),
  description: z.string().nullable(),
  updated_by: z.string().nullable(),
  updated_at: z.coerce.date()
});

export const createSystemSettingInputSchema = z.object({
  setting_key: z.string().min(1).max(100),
  setting_value: z.record(z.any()),
  setting_type: z.enum(['string', 'number', 'boolean', 'json']),
  description: z.string().max(500).nullable(),
  updated_by: z.string().nullable()
});

export const updateSystemSettingInputSchema = z.object({
  setting_key: z.string(),
  setting_value: z.record(z.any()).optional(),
  description: z.string().max(500).nullable().optional(),
  updated_by: z.string().nullable().optional()
});

export type SystemSetting = z.infer<typeof systemSettingSchema>;
export type CreateSystemSettingInput = z.infer<typeof createSystemSettingInputSchema>;
export type UpdateSystemSettingInput = z.infer<typeof updateSystemSettingInputSchema>;

// ============================================
// USER PREFERENCES SCHEMAS
// ============================================

export const userPreferenceSchema = z.object({
  preference_id: z.string(),
  user_id: z.string(),
  preferred_currency: z.string(),
  language: z.string(),
  rtl_enabled: z.boolean(),
  timezone: z.string(),
  date_format: z.string(),
  updated_at: z.coerce.date()
});

export const createUserPreferenceInputSchema = z.object({
  user_id: z.string(),
  preferred_currency: z.string().length(3).default('USD'),
  language: z.string().length(2).default('en'),
  rtl_enabled: z.boolean().default(false),
  timezone: z.string().default('UTC'),
  date_format: z.string().default('MM/DD/YYYY')
});

export const updateUserPreferenceInputSchema = z.object({
  user_id: z.string(),
  preferred_currency: z.string().length(3).optional(),
  language: z.string().length(2).optional(),
  rtl_enabled: z.boolean().optional(),
  timezone: z.string().optional(),
  date_format: z.string().optional()
});

export type UserPreference = z.infer<typeof userPreferenceSchema>;
export type CreateUserPreferenceInput = z.infer<typeof createUserPreferenceInputSchema>;
export type UpdateUserPreferenceInput = z.infer<typeof updateUserPreferenceInputSchema>;

// ============================================
// SAVED SEARCHES SCHEMAS
// ============================================

export const savedSearchSchema = z.object({
  saved_search_id: z.string(),
  user_id: z.string(),
  search_name: z.string(),
  search_query: z.string().nullable(),
  filters: z.record(z.any()).nullable(),
  sort_by: z.string().nullable(),
  alerts_enabled: z.boolean(),
  alert_frequency: z.string().nullable(),
  last_executed_at: z.coerce.date().nullable(),
  results_count: z.number().nullable(),
  created_at: z.coerce.date(),
  updated_at: z.coerce.date()
});

export const createSavedSearchInputSchema = z.object({
  user_id: z.string(),
  search_name: z.string().min(1).max(255),
  search_query: z.string().max(500).nullable(),
  filters: z.record(z.any()).nullable(),
  sort_by: z.string().max(100).nullable(),
  alerts_enabled: z.boolean().default(false),
  alert_frequency: z.enum(['immediate', 'daily', 'weekly']).nullable()
});

export const updateSavedSearchInputSchema = z.object({
  saved_search_id: z.string(),
  search_name: z.string().min(1).max(255).optional(),
  search_query: z.string().max(500).nullable().optional(),
  filters: z.record(z.any()).nullable().optional(),
  sort_by: z.string().max(100).nullable().optional(),
  alerts_enabled: z.boolean().optional(),
  alert_frequency: z.enum(['immediate', 'daily', 'weekly']).nullable().optional()
});

export type SavedSearch = z.infer<typeof savedSearchSchema>;
export type CreateSavedSearchInput = z.infer<typeof createSavedSearchInputSchema>;
export type UpdateSavedSearchInput = z.infer<typeof updateSavedSearchInputSchema>;

// ============================================
// FAVORITE PRODUCTS SCHEMAS
// ============================================

export const favoriteProductSchema = z.object({
  favorite_id: z.string(),
  user_id: z.string(),
  product_id: z.string(),
  price_alert_enabled: z.boolean(),
  last_known_price: z.number().nullable(),
  created_at: z.coerce.date()
});

export const createFavoriteProductInputSchema = z.object({
  user_id: z.string(),
  product_id: z.string(),
  price_alert_enabled: z.boolean().default(false),
  last_known_price: z.number().positive().nullable()
});

export const updateFavoriteProductInputSchema = z.object({
  favorite_id: z.string(),
  price_alert_enabled: z.boolean().optional(),
  last_known_price: z.number().positive().nullable().optional()
});

export type FavoriteProduct = z.infer<typeof favoriteProductSchema>;
export type CreateFavoriteProductInput = z.infer<typeof createFavoriteProductInputSchema>;
export type UpdateFavoriteProductInput = z.infer<typeof updateFavoriteProductInputSchema>;