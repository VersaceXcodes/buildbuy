-- ============================================
-- CREATE TABLES
-- ============================================

-- Users table (foundational)
CREATE TABLE users (
    user_id TEXT PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    full_name TEXT NOT NULL,
    phone_number TEXT,
    role TEXT NOT NULL,
    organization_id TEXT,
    organization_role TEXT,
    verification_status TEXT,
    verification_notes TEXT,
    verified_at TEXT,
    verified_by TEXT,
    primary_address TEXT,
    city TEXT,
    state TEXT,
    postal_code TEXT,
    country TEXT,
    profile_photo_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    is_suspended BOOLEAN NOT NULL DEFAULT false,
    suspension_reason TEXT,
    last_login_at TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

-- Organizations table
CREATE TABLE organizations (
    organization_id TEXT PRIMARY KEY,
    organization_name TEXT NOT NULL,
    industry TEXT,
    primary_address TEXT,
    city TEXT,
    state TEXT,
    postal_code TEXT,
    country TEXT,
    logo_url TEXT,
    website TEXT,
    description TEXT,
    created_by TEXT NOT NULL,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

-- Add foreign keys after both tables exist
ALTER TABLE users ADD CONSTRAINT fk_users_organization 
    FOREIGN KEY (organization_id) REFERENCES organizations(organization_id);
ALTER TABLE users ADD CONSTRAINT fk_users_verified_by 
    FOREIGN KEY (verified_by) REFERENCES users(user_id);
ALTER TABLE organizations ADD CONSTRAINT fk_organizations_created_by 
    FOREIGN KEY (created_by) REFERENCES users(user_id);

-- Organization invitations
CREATE TABLE organization_invitations (
    invitation_id TEXT PRIMARY KEY,
    organization_id TEXT NOT NULL REFERENCES organizations(organization_id),
    email TEXT NOT NULL,
    role TEXT NOT NULL,
    invited_by TEXT NOT NULL REFERENCES users(user_id),
    invitation_token TEXT UNIQUE NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    expires_at TEXT NOT NULL,
    accepted_at TEXT,
    created_at TEXT NOT NULL
);

-- Auth sessions
CREATE TABLE auth_sessions (
    session_id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES users(user_id),
    auth_token TEXT UNIQUE NOT NULL,
    device_name TEXT,
    browser TEXT,
    ip_address TEXT,
    location TEXT,
    expires_at TEXT NOT NULL,
    last_active_at TEXT NOT NULL,
    created_at TEXT NOT NULL
);

-- Magic links
CREATE TABLE magic_links (
    magic_link_id TEXT PRIMARY KEY,
    email TEXT NOT NULL,
    token TEXT UNIQUE NOT NULL,
    is_used BOOLEAN NOT NULL DEFAULT false,
    expires_at TEXT NOT NULL,
    used_at TEXT,
    created_at TEXT NOT NULL
);

-- Delivery addresses
CREATE TABLE delivery_addresses (
    address_id TEXT PRIMARY KEY,
    user_id TEXT REFERENCES users(user_id),
    organization_id TEXT REFERENCES organizations(organization_id),
    address_label TEXT NOT NULL,
    contact_person_name TEXT NOT NULL,
    contact_phone TEXT NOT NULL,
    address_line_1 TEXT NOT NULL,
    address_line_2 TEXT,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    postal_code TEXT NOT NULL,
    country TEXT NOT NULL,
    delivery_instructions TEXT,
    is_default BOOLEAN NOT NULL DEFAULT false,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

-- Categories
CREATE TABLE categories (
    category_id TEXT PRIMARY KEY,
    category_name TEXT NOT NULL,
    parent_category_id TEXT REFERENCES categories(category_id),
    description TEXT,
    icon_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    sort_order INTEGER,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

-- Brands
CREATE TABLE brands (
    brand_id TEXT PRIMARY KEY,
    brand_name TEXT UNIQUE NOT NULL,
    logo_url TEXT,
    website TEXT,
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

-- Unit types
CREATE TABLE unit_types (
    unit_type_id TEXT PRIMARY KEY,
    unit_name TEXT UNIQUE NOT NULL,
    unit_abbreviation TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TEXT NOT NULL
);

-- Canonical products
CREATE TABLE canonical_products (
    product_id TEXT PRIMARY KEY,
    product_name TEXT NOT NULL,
    brand_id TEXT NOT NULL REFERENCES brands(brand_id),
    model TEXT NOT NULL,
    category_id TEXT NOT NULL REFERENCES categories(category_id),
    subcategory_id TEXT REFERENCES categories(category_id),
    unit_type_id TEXT NOT NULL REFERENCES unit_types(unit_type_id),
    specifications JSON,
    description TEXT,
    status TEXT NOT NULL DEFAULT 'active',
    created_by TEXT NOT NULL REFERENCES users(user_id),
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

-- Product images
CREATE TABLE product_images (
    image_id TEXT PRIMARY KEY,
    product_id TEXT NOT NULL REFERENCES canonical_products(product_id),
    image_url TEXT NOT NULL,
    is_primary BOOLEAN NOT NULL DEFAULT false,
    sort_order INTEGER,
    uploaded_at TEXT NOT NULL
);

-- Vendor profiles
CREATE TABLE vendor_profiles (
    vendor_id TEXT PRIMARY KEY REFERENCES users(user_id),
    business_name TEXT NOT NULL,
    business_type TEXT,
    business_registration_number TEXT,
    tax_id TEXT,
    business_address TEXT,
    city TEXT,
    state TEXT,
    postal_code TEXT,
    country TEXT,
    description TEXT,
    logo_url TEXT,
    cover_image_url TEXT,
    website TEXT,
    operating_hours JSON,
    primary_color TEXT,
    average_rating NUMERIC DEFAULT 0,
    total_reviews INTEGER NOT NULL DEFAULT 0,
    total_orders INTEGER NOT NULL DEFAULT 0,
    response_time_hours NUMERIC,
    fulfillment_rate NUMERIC,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

-- Vendor documents
CREATE TABLE vendor_documents (
    document_id TEXT PRIMARY KEY,
    vendor_id TEXT NOT NULL REFERENCES vendor_profiles(vendor_id),
    document_type TEXT NOT NULL,
    file_name TEXT NOT NULL,
    file_url TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    verified_by TEXT REFERENCES users(user_id),
    verified_at TEXT,
    notes TEXT,
    uploaded_at TEXT NOT NULL
);

-- Vendor service areas
CREATE TABLE vendor_service_areas (
    service_area_id TEXT PRIMARY KEY,
    vendor_id TEXT NOT NULL REFERENCES vendor_profiles(vendor_id),
    city_id TEXT NOT NULL,
    city_name TEXT NOT NULL,
    state TEXT NOT NULL,
    delivery_available BOOLEAN NOT NULL DEFAULT true,
    delivery_fee NUMERIC,
    estimated_delivery_days INTEGER,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

-- Vendor offers
CREATE TABLE vendor_offers (
    offer_id TEXT PRIMARY KEY,
    vendor_id TEXT NOT NULL REFERENCES vendor_profiles(vendor_id),
    product_id TEXT NOT NULL REFERENCES canonical_products(product_id),
    vendor_sku TEXT,
    price NUMERIC NOT NULL,
    currency TEXT NOT NULL,
    stock_quantity INTEGER NOT NULL,
    min_order_quantity INTEGER NOT NULL,
    max_order_quantity INTEGER,
    lead_time_days INTEGER NOT NULL,
    status TEXT NOT NULL DEFAULT 'active',
    internal_notes TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

-- CSV imports
CREATE TABLE csv_imports (
    import_id TEXT PRIMARY KEY,
    vendor_id TEXT NOT NULL REFERENCES vendor_profiles(vendor_id),
    file_name TEXT NOT NULL,
    file_url TEXT,
    total_rows INTEGER NOT NULL,
    successful_rows INTEGER NOT NULL DEFAULT 0,
    failed_rows INTEGER NOT NULL DEFAULT 0,
    pending_review_rows INTEGER NOT NULL DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'processing',
    error_report_url TEXT,
    column_mapping JSON,
    created_at TEXT NOT NULL,
    completed_at TEXT
);

-- CSV import errors
CREATE TABLE csv_import_errors (
    error_id TEXT PRIMARY KEY,
    import_id TEXT NOT NULL REFERENCES csv_imports(import_id),
    row_number INTEGER NOT NULL,
    row_data JSON NOT NULL,
    error_type TEXT NOT NULL,
    error_message TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    resolved_by TEXT REFERENCES users(user_id),
    resolution_action TEXT,
    resolved_at TEXT,
    created_at TEXT NOT NULL
);

-- RFQs
CREATE TABLE rfqs (
    rfq_id TEXT PRIMARY KEY,
    rfq_number TEXT UNIQUE NOT NULL,
    buyer_id TEXT NOT NULL REFERENCES users(user_id),
    organization_id TEXT REFERENCES organizations(organization_id),
    product_id TEXT NOT NULL REFERENCES canonical_products(product_id),
    quantity INTEGER NOT NULL,
    delivery_address_id TEXT NOT NULL REFERENCES delivery_addresses(address_id),
    preferred_delivery_date TEXT,
    notes TEXT,
    status TEXT NOT NULL DEFAULT 'draft',
    expires_at TEXT,
    closed_reason TEXT,
    closed_at TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

-- RFQ attachments
CREATE TABLE rfq_attachments (
    attachment_id TEXT PRIMARY KEY,
    rfq_id TEXT NOT NULL REFERENCES rfqs(rfq_id),
    file_name TEXT NOT NULL,
    file_url TEXT NOT NULL,
    file_size INTEGER,
    uploaded_at TEXT NOT NULL
);

-- RFQ vendors
CREATE TABLE rfq_vendors (
    rfq_vendor_id TEXT PRIMARY KEY,
    rfq_id TEXT NOT NULL REFERENCES rfqs(rfq_id),
    vendor_id TEXT NOT NULL REFERENCES vendor_profiles(vendor_id),
    status TEXT NOT NULL DEFAULT 'pending',
    declined_reason TEXT,
    declined_at TEXT,
    notified_at TEXT NOT NULL
);

-- Quotes
CREATE TABLE quotes (
    quote_id TEXT PRIMARY KEY,
    rfq_id TEXT NOT NULL REFERENCES rfqs(rfq_id),
    vendor_id TEXT NOT NULL REFERENCES vendor_profiles(vendor_id),
    price_per_unit NUMERIC NOT NULL,
    currency TEXT NOT NULL,
    quantity_available INTEGER NOT NULL,
    min_order_quantity INTEGER,
    max_order_quantity INTEGER,
    delivery_fee NUMERIC,
    lead_time_days INTEGER NOT NULL,
    payment_terms TEXT NOT NULL DEFAULT 'cod',
    valid_until TEXT NOT NULL,
    notes TEXT,
    status TEXT NOT NULL DEFAULT 'submitted',
    accepted_at TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

-- Quote attachments
CREATE TABLE quote_attachments (
    attachment_id TEXT PRIMARY KEY,
    quote_id TEXT NOT NULL REFERENCES quotes(quote_id),
    file_name TEXT NOT NULL,
    file_url TEXT NOT NULL,
    file_size INTEGER,
    uploaded_at TEXT NOT NULL
);

-- Negotiations
CREATE TABLE negotiations (
    negotiation_id TEXT PRIMARY KEY,
    quote_id TEXT NOT NULL REFERENCES quotes(quote_id),
    rfq_id TEXT NOT NULL REFERENCES rfqs(rfq_id),
    round_number INTEGER NOT NULL,
    initiated_by TEXT NOT NULL,
    proposed_price NUMERIC,
    proposed_quantity INTEGER,
    proposed_terms TEXT,
    message TEXT,
    status TEXT NOT NULL,
    created_at TEXT NOT NULL
);

-- RFQ messages
CREATE TABLE rfq_messages (
    message_id TEXT PRIMARY KEY,
    rfq_id TEXT NOT NULL REFERENCES rfqs(rfq_id),
    vendor_id TEXT REFERENCES vendor_profiles(vendor_id),
    sender_id TEXT NOT NULL REFERENCES users(user_id),
    message_text TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT false,
    read_at TEXT,
    created_at TEXT NOT NULL
);

-- RFQ message attachments
CREATE TABLE rfq_message_attachments (
    attachment_id TEXT PRIMARY KEY,
    message_id TEXT NOT NULL REFERENCES rfq_messages(message_id),
    file_name TEXT NOT NULL,
    file_url TEXT NOT NULL,
    file_size INTEGER,
    uploaded_at TEXT NOT NULL
);

-- Orders
CREATE TABLE orders (
    order_id TEXT PRIMARY KEY,
    order_number TEXT UNIQUE NOT NULL,
    rfq_id TEXT NOT NULL REFERENCES rfqs(rfq_id),
    quote_id TEXT NOT NULL REFERENCES quotes(quote_id),
    buyer_id TEXT NOT NULL REFERENCES users(user_id),
    vendor_id TEXT NOT NULL REFERENCES vendor_profiles(vendor_id),
    organization_id TEXT REFERENCES organizations(organization_id),
    product_id TEXT NOT NULL REFERENCES canonical_products(product_id),
    quantity INTEGER NOT NULL,
    unit_price NUMERIC NOT NULL,
    currency TEXT NOT NULL,
    subtotal NUMERIC NOT NULL,
    delivery_fee NUMERIC,
    total_amount NUMERIC NOT NULL,
    delivery_address_id TEXT NOT NULL REFERENCES delivery_addresses(address_id),
    expected_delivery_date TEXT,
    status TEXT NOT NULL DEFAULT 'pending_vendor_confirmation',
    payment_method TEXT NOT NULL DEFAULT 'cod',
    vendor_declined_reason TEXT,
    cancelled_by TEXT,
    cancellation_reason TEXT,
    cancelled_at TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

-- Order status history
CREATE TABLE order_status_history (
    history_id TEXT PRIMARY KEY,
    order_id TEXT NOT NULL REFERENCES orders(order_id),
    previous_status TEXT,
    new_status TEXT NOT NULL,
    changed_by TEXT NOT NULL REFERENCES users(user_id),
    notes TEXT,
    created_at TEXT NOT NULL
);

-- Delivery details
CREATE TABLE delivery_details (
    delivery_id TEXT PRIMARY KEY,
    order_id TEXT UNIQUE NOT NULL REFERENCES orders(order_id),
    driver_name TEXT,
    driver_contact TEXT,
    vehicle_number TEXT,
    estimated_delivery_time TEXT,
    actual_delivery_time TEXT,
    recipient_name TEXT,
    signature_url TEXT,
    delivery_photo_url TEXT,
    delivery_notes TEXT,
    marked_dispatched_at TEXT,
    marked_delivered_at TEXT
);

-- Cash collections
CREATE TABLE cash_collections (
    collection_id TEXT PRIMARY KEY,
    order_id TEXT UNIQUE NOT NULL REFERENCES orders(order_id),
    amount_collected NUMERIC NOT NULL,
    collected_by TEXT NOT NULL,
    collection_timestamp TEXT NOT NULL,
    notes TEXT,
    receipt_number TEXT,
    reconciliation_status TEXT NOT NULL DEFAULT 'pending',
    reconciled_at TEXT,
    payout_date TEXT,
    payout_reference TEXT,
    created_at TEXT NOT NULL
);

-- Order documents
CREATE TABLE order_documents (
    document_id TEXT PRIMARY KEY,
    order_id TEXT NOT NULL REFERENCES orders(order_id),
    document_type TEXT NOT NULL,
    file_name TEXT NOT NULL,
    file_url TEXT NOT NULL,
    uploaded_by TEXT NOT NULL REFERENCES users(user_id),
    uploaded_at TEXT NOT NULL
);

-- Order messages
CREATE TABLE order_messages (
    message_id TEXT PRIMARY KEY,
    order_id TEXT NOT NULL REFERENCES orders(order_id),
    sender_id TEXT NOT NULL REFERENCES users(user_id),
    message_text TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT false,
    read_at TEXT,
    created_at TEXT NOT NULL
);

-- Order message attachments
CREATE TABLE order_message_attachments (
    attachment_id TEXT PRIMARY KEY,
    message_id TEXT NOT NULL REFERENCES order_messages(message_id),
    file_name TEXT NOT NULL,
    file_url TEXT NOT NULL,
    file_size INTEGER,
    uploaded_at TEXT NOT NULL
);

-- Disputes
CREATE TABLE disputes (
    dispute_id TEXT PRIMARY KEY,
    order_id TEXT NOT NULL REFERENCES orders(order_id),
    raised_by TEXT NOT NULL REFERENCES users(user_id),
    issue_type TEXT NOT NULL,
    description TEXT NOT NULL,
    preferred_resolution TEXT,
    status TEXT NOT NULL DEFAULT 'open',
    assigned_to TEXT REFERENCES users(user_id),
    resolution_decision TEXT,
    resolution_notes TEXT,
    resolution_action TEXT,
    resolved_by TEXT REFERENCES users(user_id),
    resolved_at TEXT,
    closed_at TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

-- Dispute evidence
CREATE TABLE dispute_evidence (
    evidence_id TEXT PRIMARY KEY,
    dispute_id TEXT NOT NULL REFERENCES disputes(dispute_id),
    uploaded_by TEXT NOT NULL REFERENCES users(user_id),
    file_name TEXT NOT NULL,
    file_url TEXT NOT NULL,
    file_type TEXT NOT NULL,
    uploaded_at TEXT NOT NULL
);

-- Dispute messages
CREATE TABLE dispute_messages (
    message_id TEXT PRIMARY KEY,
    dispute_id TEXT NOT NULL REFERENCES disputes(dispute_id),
    sender_id TEXT NOT NULL REFERENCES users(user_id),
    recipient_ids JSON NOT NULL,
    message_text TEXT NOT NULL,
    created_at TEXT NOT NULL
);

-- Reviews
CREATE TABLE reviews (
    review_id TEXT PRIMARY KEY,
    order_id TEXT UNIQUE NOT NULL REFERENCES orders(order_id),
    buyer_id TEXT NOT NULL REFERENCES users(user_id),
    vendor_id TEXT NOT NULL REFERENCES vendor_profiles(vendor_id),
    overall_rating NUMERIC NOT NULL,
    product_quality_rating NUMERIC,
    delivery_rating NUMERIC,
    communication_rating NUMERIC,
    pricing_rating NUMERIC,
    review_text TEXT,
    is_anonymous BOOLEAN NOT NULL DEFAULT false,
    helpful_count INTEGER NOT NULL DEFAULT 0,
    is_verified_purchase BOOLEAN NOT NULL DEFAULT true,
    vendor_response TEXT,
    vendor_response_at TEXT,
    status TEXT NOT NULL DEFAULT 'published',
    hidden_reason TEXT,
    hidden_by TEXT REFERENCES users(user_id),
    hidden_at TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

-- Review photos
CREATE TABLE review_photos (
    photo_id TEXT PRIMARY KEY,
    review_id TEXT NOT NULL REFERENCES reviews(review_id),
    photo_url TEXT NOT NULL,
    uploaded_at TEXT NOT NULL
);

-- Review helpfulness
CREATE TABLE review_helpfulness (
    helpfulness_id TEXT PRIMARY KEY,
    review_id TEXT NOT NULL REFERENCES reviews(review_id),
    user_id TEXT NOT NULL REFERENCES users(user_id),
    created_at TEXT NOT NULL
);

-- Notifications
CREATE TABLE notifications (
    notification_id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES users(user_id),
    notification_type TEXT NOT NULL,
    category TEXT NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    link_url TEXT,
    entity_type TEXT,
    entity_id TEXT,
    is_read BOOLEAN NOT NULL DEFAULT false,
    read_at TEXT,
    is_archived BOOLEAN NOT NULL DEFAULT false,
    archived_at TEXT,
    created_at TEXT NOT NULL
);

-- Notification preferences
CREATE TABLE notification_preferences (
    preference_id TEXT PRIMARY KEY,
    user_id TEXT UNIQUE NOT NULL REFERENCES users(user_id),
    email_notifications JSON NOT NULL,
    in_app_notifications JSON NOT NULL,
    sms_notifications JSON NOT NULL,
    quiet_hours_start TEXT,
    quiet_hours_end TEXT,
    digest_frequency TEXT,
    updated_at TEXT NOT NULL
);

-- Saved searches
CREATE TABLE saved_searches (
    saved_search_id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES users(user_id),
    search_name TEXT NOT NULL,
    search_query TEXT,
    filters JSON,
    sort_by TEXT,
    alerts_enabled BOOLEAN NOT NULL DEFAULT false,
    alert_frequency TEXT,
    last_executed_at TEXT,
    results_count INTEGER,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

-- Favorite products
CREATE TABLE favorite_products (
    favorite_id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES users(user_id),
    product_id TEXT NOT NULL REFERENCES canonical_products(product_id),
    price_alert_enabled BOOLEAN NOT NULL DEFAULT false,
    last_known_price NUMERIC,
    created_at TEXT NOT NULL
);

-- Favorite vendors
CREATE TABLE favorite_vendors (
    favorite_id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES users(user_id),
    vendor_id TEXT NOT NULL REFERENCES vendor_profiles(vendor_id),
    created_at TEXT NOT NULL
);

-- Recently viewed products
CREATE TABLE recently_viewed_products (
    view_id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES users(user_id),
    product_id TEXT NOT NULL REFERENCES canonical_products(product_id),
    viewed_at TEXT NOT NULL
);

-- User preferences
CREATE TABLE user_preferences (
    preference_id TEXT PRIMARY KEY,
    user_id TEXT UNIQUE NOT NULL REFERENCES users(user_id),
    preferred_currency TEXT NOT NULL DEFAULT 'USD',
    language TEXT NOT NULL DEFAULT 'en',
    rtl_enabled BOOLEAN NOT NULL DEFAULT false,
    timezone TEXT NOT NULL DEFAULT 'UTC',
    date_format TEXT NOT NULL DEFAULT 'MM/DD/YYYY',
    updated_at TEXT NOT NULL
);

-- API keys
CREATE TABLE api_keys (
    api_key_id TEXT PRIMARY KEY,
    vendor_id TEXT NOT NULL REFERENCES vendor_profiles(vendor_id),
    key_name TEXT NOT NULL,
    api_key TEXT UNIQUE NOT NULL,
    permissions JSON NOT NULL,
    expires_at TEXT,
    last_used_at TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TEXT NOT NULL
);

-- Webhooks
CREATE TABLE webhooks (
    webhook_id TEXT PRIMARY KEY,
    vendor_id TEXT NOT NULL REFERENCES vendor_profiles(vendor_id),
    endpoint_url TEXT NOT NULL,
    secret_key TEXT NOT NULL,
    events JSON NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

-- Webhook logs
CREATE TABLE webhook_logs (
    log_id TEXT PRIMARY KEY,
    webhook_id TEXT NOT NULL REFERENCES webhooks(webhook_id),
    event_type TEXT NOT NULL,
    payload JSON NOT NULL,
    response_status INTEGER,
    response_body TEXT,
    retry_count INTEGER NOT NULL DEFAULT 0,
    status TEXT NOT NULL,
    created_at TEXT NOT NULL
);

-- Audit logs
CREATE TABLE audit_logs (
    log_id TEXT PRIMARY KEY,
    user_id TEXT REFERENCES users(user_id),
    action_type TEXT NOT NULL,
    entity_type TEXT,
    entity_id TEXT,
    old_value JSON,
    new_value JSON,
    ip_address TEXT,
    user_agent TEXT,
    details JSON,
    created_at TEXT NOT NULL
);

-- System settings
CREATE TABLE system_settings (
    setting_key TEXT PRIMARY KEY,
    setting_value JSON NOT NULL,
    setting_type TEXT NOT NULL,
    description TEXT,
    updated_by TEXT REFERENCES users(user_id),
    updated_at TEXT NOT NULL
);

-- Currencies
CREATE TABLE currencies (
    currency_code TEXT PRIMARY KEY,
    currency_name TEXT NOT NULL,
    symbol TEXT NOT NULL,
    exchange_rate_to_base NUMERIC NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    last_updated TEXT NOT NULL
);

-- Cities
CREATE TABLE cities (
    city_id TEXT PRIMARY KEY,
    city_name TEXT NOT NULL,
    state TEXT NOT NULL,
    country TEXT NOT NULL,
    latitude NUMERIC,
    longitude NUMERIC,
    is_active BOOLEAN NOT NULL DEFAULT true
);

-- Product merges
CREATE TABLE product_merges (
    merge_id TEXT PRIMARY KEY,
    primary_product_id TEXT NOT NULL REFERENCES canonical_products(product_id),
    merged_product_ids JSON NOT NULL,
    merged_by TEXT NOT NULL REFERENCES users(user_id),
    merged_at TEXT NOT NULL,
    is_reversed BOOLEAN NOT NULL DEFAULT false,
    reversed_by TEXT REFERENCES users(user_id),
    reversed_at TEXT
);

-- Announcements
CREATE TABLE announcements (
    announcement_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    target_audience TEXT NOT NULL,
    display_type TEXT NOT NULL,
    start_date TEXT NOT NULL,
    end_date TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_by TEXT NOT NULL REFERENCES users(user_id),
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

-- Price history
CREATE TABLE price_history (
    history_id TEXT PRIMARY KEY,
    offer_id TEXT NOT NULL REFERENCES vendor_offers(offer_id),
    product_id TEXT NOT NULL REFERENCES canonical_products(product_id),
    vendor_id TEXT NOT NULL REFERENCES vendor_profiles(vendor_id),
    price NUMERIC NOT NULL,
    currency TEXT NOT NULL,
    recorded_at TEXT NOT NULL
);

-- Email logs
CREATE TABLE email_logs (
    email_log_id TEXT PRIMARY KEY,
    recipient_email TEXT NOT NULL,
    email_type TEXT NOT NULL,
    subject TEXT NOT NULL,
    status TEXT NOT NULL,
    sent_at TEXT,
    delivered_at TEXT,
    opened_at TEXT,
    clicked_at TEXT,
    error_message TEXT,
    created_at TEXT NOT NULL
);

-- SMS logs
CREATE TABLE sms_logs (
    sms_log_id TEXT PRIMARY KEY,
    recipient_phone TEXT NOT NULL,
    sms_type TEXT NOT NULL,
    message TEXT NOT NULL,
    status TEXT NOT NULL,
    sent_at TEXT,
    delivered_at TEXT,
    error_message TEXT,
    created_at TEXT NOT NULL
);

-- ============================================
-- SEED DATA
-- ============================================

-- Seed Users (admin, buyers, vendors)
INSERT INTO users (user_id, email, password_hash, full_name, phone_number, role, organization_id, organization_role, verification_status, verification_notes, verified_at, verified_by, primary_address, city, state, postal_code, country, profile_photo_url, is_active, is_suspended, suspension_reason, last_login_at, created_at, updated_at) VALUES
('user_admin_001', 'admin@platform.com', 'admin123', 'Platform Administrator', '+1234567890', 'admin', NULL, NULL, 'verified', 'Platform admin account', '2024-01-01T00:00:00Z', NULL, '123 Admin Street', 'New York', 'NY', '10001', 'USA', 'https://picsum.photos/seed/admin001/200', true, false, NULL, '2024-01-15T10:30:00Z', '2024-01-01T00:00:00Z', '2024-01-15T10:30:00Z'),
('user_buyer_001', 'john.buyer@email.com', 'password123', 'John Buyer', '+1234567891', 'buyer', NULL, NULL, 'verified', 'Active buyer', '2024-01-02T00:00:00Z', 'user_admin_001', '456 Buyer Avenue', 'Los Angeles', 'CA', '90001', 'USA', 'https://picsum.photos/seed/buyer001/200', true, false, NULL, '2024-01-15T09:00:00Z', '2024-01-02T00:00:00Z', '2024-01-15T09:00:00Z'),
('user_buyer_002', 'sarah.procurement@email.com', 'password123', 'Sarah Procurement', '+1234567892', 'buyer', NULL, NULL, 'verified', 'Corporate buyer', '2024-01-03T00:00:00Z', 'user_admin_001', '789 Corporate Blvd', 'Chicago', 'IL', '60601', 'USA', 'https://picsum.photos/seed/buyer002/200', true, false, NULL, '2024-01-15T08:45:00Z', '2024-01-03T00:00:00Z', '2024-01-15T08:45:00Z'),
('user_buyer_003', 'mike.johnson@email.com', 'password123', 'Mike Johnson', '+1234567893', 'buyer', NULL, NULL, 'verified', 'Frequent buyer', '2024-01-04T00:00:00Z', 'user_admin_001', '321 Market Street', 'Houston', 'TX', '77001', 'USA', 'https://picsum.photos/seed/buyer003/200', true, false, NULL, '2024-01-14T16:20:00Z', '2024-01-04T00:00:00Z', '2024-01-14T16:20:00Z'),
('user_vendor_001', 'vendor1@supplies.com', 'vendor123', 'Alex Vendor', '+1234567894', 'vendor', NULL, NULL, 'verified', 'Top rated vendor', '2024-01-05T00:00:00Z', 'user_admin_001', '111 Warehouse Road', 'Dallas', 'TX', '75201', 'USA', 'https://picsum.photos/seed/vendor001/200', true, false, NULL, '2024-01-15T07:15:00Z', '2024-01-05T00:00:00Z', '2024-01-15T07:15:00Z'),
('user_vendor_002', 'vendor2@electronics.com', 'vendor123', 'Maria Electronics', '+1234567895', 'vendor', NULL, NULL, 'verified', 'Electronics specialist', '2024-01-06T00:00:00Z', 'user_admin_001', '222 Tech Park', 'San Francisco', 'CA', '94102', 'USA', 'https://picsum.photos/seed/vendor002/200', true, false, NULL, '2024-01-15T06:30:00Z', '2024-01-06T00:00:00Z', '2024-01-15T06:30:00Z'),
('user_vendor_003', 'vendor3@furniture.com', 'vendor123', 'Robert Furniture', '+1234567896', 'vendor', NULL, NULL, 'verified', 'Furniture supplier', '2024-01-07T00:00:00Z', 'user_admin_001', '333 Industrial Ave', 'Miami', 'FL', '33101', 'USA', 'https://picsum.photos/seed/vendor003/200', true, false, NULL, '2024-01-14T18:00:00Z', '2024-01-07T00:00:00Z', '2024-01-14T18:00:00Z'),
('user_vendor_004', 'vendor4@office.com', 'vendor123', 'Linda Office Supply', '+1234567897', 'vendor', NULL, NULL, 'verified', 'Office supplies vendor', '2024-01-08T00:00:00Z', 'user_admin_001', '444 Commerce Street', 'Seattle', 'WA', '98101', 'USA', 'https://picsum.photos/seed/vendor004/200', true, false, NULL, '2024-01-15T05:45:00Z', '2024-01-08T00:00:00Z', '2024-01-15T05:45:00Z'),
('user_buyer_004', 'emma.wilson@email.com', 'password123', 'Emma Wilson', '+1234567898', 'buyer', NULL, NULL, 'pending', 'New user pending verification', NULL, NULL, '555 Oak Street', 'Boston', 'MA', '02101', 'USA', 'https://picsum.photos/seed/buyer004/200', true, false, NULL, '2024-01-14T14:00:00Z', '2024-01-14T00:00:00Z', '2024-01-14T14:00:00Z'),
('user_vendor_005', 'vendor5@construction.com', 'vendor123', 'David Construction', '+1234567899', 'vendor', NULL, NULL, 'verified', 'Construction materials', '2024-01-09T00:00:00Z', 'user_admin_001', '666 Builder Lane', 'Phoenix', 'AZ', '85001', 'USA', 'https://picsum.photos/seed/vendor005/200', true, false, NULL, '2024-01-15T04:30:00Z', '2024-01-09T00:00:00Z', '2024-01-15T04:30:00Z');

-- Seed Organizations
INSERT INTO organizations (organization_id, organization_name, industry, primary_address, city, state, postal_code, country, logo_url, website, description, created_by, created_at, updated_at) VALUES
('org_001', 'TechCorp Industries', 'Technology', '1000 Tech Plaza', 'San Jose', 'CA', '95101', 'USA', 'https://picsum.photos/seed/org001/200', 'https://techcorp.example.com', 'Leading technology solutions provider', 'user_admin_001', '2024-01-10T00:00:00Z', '2024-01-10T00:00:00Z'),
('org_002', 'Global Manufacturing Ltd', 'Manufacturing', '2000 Factory Road', 'Detroit', 'MI', '48201', 'USA', 'https://picsum.photos/seed/org002/200', 'https://globalmanuf.example.com', 'International manufacturing company', 'user_admin_001', '2024-01-11T00:00:00Z', '2024-01-11T00:00:00Z'),
('org_003', 'Retail Solutions Inc', 'Retail', '3000 Shopping Center', 'Atlanta', 'GA', '30301', 'USA', 'https://picsum.photos/seed/org003/200', 'https://retailsol.example.com', 'Retail and distribution network', 'user_buyer_002', '2024-01-12T00:00:00Z', '2024-01-12T00:00:00Z');

-- Update users with organizations
UPDATE users SET organization_id = 'org_001', organization_role = 'procurement_manager' WHERE user_id = 'user_buyer_002';
UPDATE users SET organization_id = 'org_002', organization_role = 'buyer' WHERE user_id = 'user_buyer_003';

-- Seed Organization Invitations
INSERT INTO organization_invitations (invitation_id, organization_id, email, role, invited_by, invitation_token, status, expires_at, accepted_at, created_at) VALUES
('invite_001', 'org_001', 'newuser@techcorp.com', 'buyer', 'user_buyer_002', 'token_abc123xyz', 'pending', '2024-02-15T00:00:00Z', NULL, '2024-01-15T00:00:00Z'),
('invite_002', 'org_002', 'buyer@globalmanuf.com', 'procurement_manager', 'user_buyer_003', 'token_def456uvw', 'pending', '2024-02-20T00:00:00Z', NULL, '2024-01-14T00:00:00Z'),
('invite_003', 'org_001', 'accepted@techcorp.com', 'buyer', 'user_buyer_002', 'token_ghi789rst', 'accepted', '2024-02-10T00:00:00Z', '2024-01-12T00:00:00Z', '2024-01-10T00:00:00Z');

-- Seed Auth Sessions
INSERT INTO auth_sessions (session_id, user_id, auth_token, device_name, browser, ip_address, location, expires_at, last_active_at, created_at) VALUES
('session_001', 'user_buyer_001', 'token_buyer001_session1', 'iPhone 13', 'Safari', '192.168.1.100', 'Los Angeles, CA', '2024-02-15T10:00:00Z', '2024-01-15T09:00:00Z', '2024-01-15T08:00:00Z'),
('session_002', 'user_vendor_001', 'token_vendor001_session1', 'MacBook Pro', 'Chrome', '192.168.1.101', 'Dallas, TX', '2024-02-15T08:00:00Z', '2024-01-15T07:15:00Z', '2024-01-15T06:00:00Z'),
('session_003', 'user_buyer_002', 'token_buyer002_session1', 'Windows PC', 'Firefox', '192.168.1.102', 'Chicago, IL', '2024-02-15T09:00:00Z', '2024-01-15T08:45:00Z', '2024-01-15T07:30:00Z'),
('session_004', 'user_vendor_002', 'token_vendor002_session1', 'Android Phone', 'Chrome', '192.168.1.103', 'San Francisco, CA', '2024-02-15T07:00:00Z', '2024-01-15T06:30:00Z', '2024-01-15T05:00:00Z');

-- Seed Magic Links
INSERT INTO magic_links (magic_link_id, email, token, is_used, expires_at, used_at, created_at) VALUES
('magic_001', 'john.buyer@email.com', 'magic_token_123abc', true, '2024-01-15T10:00:00Z', '2024-01-15T09:05:00Z', '2024-01-15T09:00:00Z'),
('magic_002', 'newuser@example.com', 'magic_token_456def', false, '2024-01-16T10:00:00Z', NULL, '2024-01-15T10:00:00Z'),
('magic_003', 'vendor1@supplies.com', 'magic_token_789ghi', true, '2024-01-14T10:00:00Z', '2024-01-14T09:30:00Z', '2024-01-14T09:00:00Z');

-- Seed Delivery Addresses
INSERT INTO delivery_addresses (address_id, user_id, organization_id, address_label, contact_person_name, contact_phone, address_line_1, address_line_2, city, state, postal_code, country, delivery_instructions, is_default, created_at, updated_at) VALUES
('addr_001', 'user_buyer_001', NULL, 'Home', 'John Buyer', '+1234567891', '456 Buyer Avenue', 'Apt 5B', 'Los Angeles', 'CA', '90001', 'USA', 'Ring doorbell twice', true, '2024-01-02T00:00:00Z', '2024-01-02T00:00:00Z'),
('addr_002', 'user_buyer_001', NULL, 'Office', 'John Buyer', '+1234567891', '789 Business Park', 'Suite 200', 'Los Angeles', 'CA', '90002', 'USA', 'Reception on 2nd floor', false, '2024-01-03T00:00:00Z', '2024-01-03T00:00:00Z'),
('addr_003', 'user_buyer_002', 'org_001', 'TechCorp Warehouse', 'Sarah Procurement', '+1234567892', '1000 Tech Plaza', 'Loading Dock B', 'San Jose', 'CA', '95101', 'USA', 'Call 30 minutes before delivery', true, '2024-01-03T00:00:00Z', '2024-01-03T00:00:00Z'),
('addr_004', 'user_buyer_003', 'org_002', 'Main Factory', 'Mike Johnson', '+1234567893', '2000 Factory Road', 'Receiving Bay 3', 'Detroit', 'MI', '48201', 'USA', 'Use east entrance for deliveries', true, '2024-01-04T00:00:00Z', '2024-01-04T00:00:00Z'),
('addr_005', 'user_buyer_003', NULL, 'Home Address', 'Mike Johnson', '+1234567893', '321 Market Street', NULL, 'Houston', 'TX', '77001', 'USA', 'Leave with neighbor if not home', false, '2024-01-05T00:00:00Z', '2024-01-05T00:00:00Z');

-- Seed Categories (with parent-child relationships)
INSERT INTO categories (category_id, category_name, parent_category_id, description, icon_url, is_active, sort_order, created_at, updated_at) VALUES
('cat_001', 'Electronics', NULL, 'Electronic devices and components', 'https://picsum.photos/seed/cat001/100', true, 1, '2024-01-01T00:00:00Z', '2024-01-01T00:00:00Z'),
('cat_002', 'Furniture', NULL, 'Office and home furniture', 'https://picsum.photos/seed/cat002/100', true, 2, '2024-01-01T00:00:00Z', '2024-01-01T00:00:00Z'),
('cat_003', 'Office Supplies', NULL, 'General office supplies', 'https://picsum.photos/seed/cat003/100', true, 3, '2024-01-01T00:00:00Z', '2024-01-01T00:00:00Z'),
('cat_004', 'Construction Materials', NULL, 'Building and construction materials', 'https://picsum.photos/seed/cat004/100', true, 4, '2024-01-01T00:00:00Z', '2024-01-01T00:00:00Z'),
('cat_005', 'Computers', 'cat_001', 'Desktop and laptop computers', 'https://picsum.photos/seed/cat005/100', true, 1, '2024-01-01T00:00:00Z', '2024-01-01T00:00:00Z'),
('cat_006', 'Monitors', 'cat_001', 'Computer monitors and displays', 'https://picsum.photos/seed/cat006/100', true, 2, '2024-01-01T00:00:00Z', '2024-01-01T00:00:00Z'),
('cat_007', 'Office Chairs', 'cat_002', 'Ergonomic office seating', 'https://picsum.photos/seed/cat007/100', true, 1, '2024-01-01T00:00:00Z', '2024-01-01T00:00:00Z'),
('cat_008', 'Desks', 'cat_002', 'Office and home desks', 'https://picsum.photos/seed/cat008/100', true, 2, '2024-01-01T00:00:00Z', '2024-01-01T00:00:00Z');

-- Seed Brands
INSERT INTO brands (brand_id, brand_name, logo_url, website, description, is_active, created_at, updated_at) VALUES
('brand_001', 'Dell', 'https://picsum.photos/seed/brand001/100', 'https://dell.example.com', 'Computer technology company', true, '2024-01-01T00:00:00Z', '2024-01-01T00:00:00Z'),
('brand_002', 'HP', 'https://picsum.photos/seed/brand002/100', 'https://hp.example.com', 'Technology and printing solutions', true, '2024-01-01T00:00:00Z', '2024-01-01T00:00:00Z'),
('brand_003', 'Samsung', 'https://picsum.photos/seed/brand003/100', 'https://samsung.example.com', 'Electronics manufacturer', true, '2024-01-01T00:00:00Z', '2024-01-01T00:00:00Z'),
('brand_004', 'Herman Miller', 'https://picsum.photos/seed/brand004/100', 'https://hermanmiller.example.com', 'Premium office furniture', true, '2024-01-01T00:00:00Z', '2024-01-01T00:00:00Z'),
('brand_005', 'Steelcase', 'https://picsum.photos/seed/brand005/100', 'https://steelcase.example.com', 'Office furniture and architecture', true, '2024-01-01T00:00:00Z', '2024-01-01T00:00:00Z'),
('brand_006', 'Logitech', 'https://picsum.photos/seed/brand006/100', 'https://logitech.example.com', 'Computer peripherals', true, '2024-01-01T00:00:00Z', '2024-01-01T00:00:00Z'),
('brand_007', 'Canon', 'https://picsum.photos/seed/brand007/100', 'https://canon.example.com', 'Imaging and optical products', true, '2024-01-01T00:00:00Z', '2024-01-01T00:00:00Z');

-- Seed Unit Types
INSERT INTO unit_types (unit_type_id, unit_name, unit_abbreviation, is_active, created_at) VALUES
('unit_001', 'Piece', 'pc', true, '2024-01-01T00:00:00Z'),
('unit_002', 'Box', 'box', true, '2024-01-01T00:00:00Z'),
('unit_003', 'Carton', 'ctn', true, '2024-01-01T00:00:00Z'),
('unit_004', 'Pack', 'pk', true, '2024-01-01T00:00:00Z'),
('unit_005', 'Set', 'set', true, '2024-01-01T00:00:00Z'),
('unit_006', 'Unit', 'unit', true, '2024-01-01T00:00:00Z'),
('unit_007', 'Roll', 'roll', true, '2024-01-01T00:00:00Z');

-- Seed Canonical Products
INSERT INTO canonical_products (product_id, product_name, brand_id, model, category_id, subcategory_id, unit_type_id, specifications, description, status, created_by, created_at, updated_at) VALUES
('prod_001', 'Dell Latitude 5420 Laptop', 'brand_001', 'LAT-5420-I7', 'cat_001', 'cat_005', 'unit_001', '{"processor": "Intel Core i7-1185G7", "ram": "16GB", "storage": "512GB SSD", "display": "14 inch FHD", "warranty": "3 years"}', 'Professional business laptop with excellent performance', 'active', 'user_admin_001', '2024-01-05T00:00:00Z', '2024-01-05T00:00:00Z'),
('prod_002', 'HP EliteDisplay E243 Monitor', 'brand_002', 'E243-24IN', 'cat_001', 'cat_006', 'unit_001', '{"size": "24 inch", "resolution": "1920x1080", "panel": "IPS", "refresh_rate": "60Hz", "ports": "HDMI, DisplayPort, VGA"}', '24-inch Full HD business monitor', 'active', 'user_admin_001', '2024-01-05T00:00:00Z', '2024-01-05T00:00:00Z'),
('prod_003', 'Samsung 27-inch Curved Monitor', 'brand_003', 'C27F390', 'cat_001', 'cat_006', 'unit_001', '{"size": "27 inch", "resolution": "1920x1080", "curvature": "1800R", "refresh_rate": "60Hz", "response_time": "4ms"}', 'Immersive curved display for productivity', 'active', 'user_admin_001', '2024-01-05T00:00:00Z', '2024-01-05T00:00:00Z'),
('prod_004', 'Herman Miller Aeron Chair', 'brand_004', 'AERON-B-GRAPHITE', 'cat_002', 'cat_007', 'unit_001', '{"size": "B (Medium)", "material": "Pellicle mesh", "adjustments": "Tilt, lumbar, armrest", "weight_capacity": "350 lbs", "warranty": "12 years"}', 'Iconic ergonomic office chair', 'active', 'user_admin_001', '2024-01-05T00:00:00Z', '2024-01-05T00:00:00Z'),
('prod_005', 'Steelcase Series 1 Office Chair', 'brand_005', 'SERIES1-BLACK', 'cat_002', 'cat_007', 'unit_001', '{"material": "Mesh back", "adjustments": "Height, tilt, armrest", "weight_capacity": "300 lbs", "warranty": "10 years"}', 'Affordable ergonomic seating solution', 'active', 'user_admin_001', '2024-01-05T00:00:00Z', '2024-01-05T00:00:00Z'),
('prod_006', 'Logitech MX Master 3 Mouse', 'brand_006', 'MX-MASTER-3', 'cat_001', 'cat_005', 'unit_001', '{"connectivity": "Bluetooth, USB", "buttons": "7", "sensor": "4000 DPI", "battery": "70 days", "compatibility": "Windows, Mac, Linux"}', 'Advanced wireless mouse for professionals', 'active', 'user_admin_001', '2024-01-05T00:00:00Z', '2024-01-05T00:00:00Z'),
('prod_007', 'Canon imageCLASS Printer', 'brand_007', 'MF445DW', 'cat_001', 'cat_005', 'unit_001', '{"type": "Laser multifunction", "print_speed": "40 ppm", "connectivity": "WiFi, Ethernet, USB", "duplex": "Automatic", "capacity": "250 sheets"}', 'Reliable office laser printer', 'active', 'user_admin_001', '2024-01-05T00:00:00Z', '2024-01-05T00:00:00Z'),
('prod_008', 'HP LaserJet Pro Printer', 'brand_002', 'M404DN', 'cat_001', 'cat_005', 'unit_001', '{"type": "Laser printer", "print_speed": "40 ppm", "connectivity": "Ethernet, USB", "duplex": "Automatic", "capacity": "350 sheets"}', 'Fast and efficient office printing', 'active', 'user_admin_001', '2024-01-06T00:00:00Z', '2024-01-06T00:00:00Z'),
('prod_009', 'Standing Desk Adjustable', 'brand_005', 'SD-PRO-60', 'cat_002', 'cat_008', 'unit_001', '{"size": "60x30 inches", "height_range": "25-50 inches", "motor": "Dual", "weight_capacity": "300 lbs", "memory_presets": "4"}', 'Electric height-adjustable standing desk', 'active', 'user_admin_001', '2024-01-06T00:00:00Z', '2024-01-06T00:00:00Z'),
('prod_010', 'Dell UltraSharp 32 Monitor', 'brand_001', 'U3223QE', 'cat_001', 'cat_006', 'unit_001', '{"size": "32 inch", "resolution": "3840x2160", "panel": "IPS Black", "color_gamut": "99% sRGB", "ports": "USB-C, HDMI, DisplayPort"}', 'Professional 4K monitor with USB-C', 'active', 'user_admin_001', '2024-01-06T00:00:00Z', '2024-01-06T00:00:00Z');

-- Seed Product Images
INSERT INTO product_images (image_id, product_id, image_url, is_primary, sort_order, uploaded_at) VALUES
('img_001', 'prod_001', 'https://picsum.photos/seed/prod001-1/800', true, 1, '2024-01-05T00:00:00Z'),
('img_002', 'prod_001', 'https://picsum.photos/seed/prod001-2/800', false, 2, '2024-01-05T00:00:00Z'),
('img_003', 'prod_001', 'https://picsum.photos/seed/prod001-3/800', false, 3, '2024-01-05T00:00:00Z'),
('img_004', 'prod_002', 'https://picsum.photos/seed/prod002-1/800', true, 1, '2024-01-05T00:00:00Z'),
('img_005', 'prod_002', 'https://picsum.photos/seed/prod002-2/800', false, 2, '2024-01-05T00:00:00Z'),
('img_006', 'prod_003', 'https://picsum.photos/seed/prod003-1/800', true, 1, '2024-01-05T00:00:00Z'),
('img_007', 'prod_004', 'https://picsum.photos/seed/prod004-1/800', true, 1, '2024-01-05T00:00:00Z'),
('img_008', 'prod_004', 'https://picsum.photos/seed/prod004-2/800', false, 2, '2024-01-05T00:00:00Z'),
('img_009', 'prod_005', 'https://picsum.photos/seed/prod005-1/800', true, 1, '2024-01-05T00:00:00Z'),
('img_010', 'prod_006', 'https://picsum.photos/seed/prod006-1/800', true, 1, '2024-01-05T00:00:00Z'),
('img_011', 'prod_007', 'https://picsum.photos/seed/prod007-1/800', true, 1, '2024-01-05T00:00:00Z'),
('img_012', 'prod_008', 'https://picsum.photos/seed/prod008-1/800', true, 1, '2024-01-05T00:00:00Z'),
('img_013', 'prod_009', 'https://picsum.photos/seed/prod009-1/800', true, 1, '2024-01-05T00:00:00Z'),
('img_014', 'prod_009', 'https://picsum.photos/seed/prod009-2/800', false, 2, '2024-01-05T00:00:00Z'),
('img_015', 'prod_010', 'https://picsum.photos/seed/prod010-1/800', true, 1, '2024-01-06T00:00:00Z');

-- Seed Vendor Profiles
INSERT INTO vendor_profiles (vendor_id, business_name, business_type, business_registration_number, tax_id, business_address, city, state, postal_code, country, description, logo_url, cover_image_url, website, operating_hours, primary_color, average_rating, total_reviews, total_orders, response_time_hours, fulfillment_rate, created_at, updated_at) VALUES
('user_vendor_001', 'Premium Office Supplies Co.', 'LLC', 'REG-123456', 'TAX-789012', '111 Warehouse Road', 'Dallas', 'TX', '75201', 'USA', 'Your trusted partner for quality office supplies and equipment', 'https://picsum.photos/seed/vend001-logo/200', 'https://picsum.photos/seed/vend001-cover/1200/400', 'https://premiumoffice.example.com', '{"monday": "8:00-18:00", "tuesday": "8:00-18:00", "wednesday": "8:00-18:00", "thursday": "8:00-18:00", "friday": "8:00-18:00", "saturday": "9:00-14:00", "sunday": "closed"}', '#2563eb', 4.7, 152, 487, 2.5, 98.5, '2024-01-05T00:00:00Z', '2024-01-15T00:00:00Z'),
('user_vendor_002', 'TechZone Electronics', 'Corporation', 'REG-234567', 'TAX-890123', '222 Tech Park', 'San Francisco', 'CA', '94102', 'USA', 'Leading supplier of electronics and computer equipment for businesses', 'https://picsum.photos/seed/vend002-logo/200', 'https://picsum.photos/seed/vend002-cover/1200/400', 'https://techzone.example.com', '{"monday": "9:00-19:00", "tuesday": "9:00-19:00", "wednesday": "9:00-19:00", "thursday": "9:00-19:00", "friday": "9:00-19:00", "saturday": "10:00-16:00", "sunday": "closed"}', '#10b981', 4.9, 203, 612, 1.8, 99.2, '2024-01-06T00:00:00Z', '2024-01-15T00:00:00Z'),
('user_vendor_003', 'Modern Furniture Solutions', 'LLC', 'REG-345678', 'TAX-901234', '333 Industrial Ave', 'Miami', 'FL', '33101', 'USA', 'Contemporary office and home furniture at competitive prices', 'https://picsum.photos/seed/vend003-logo/200', 'https://picsum.photos/seed/vend003-cover/1200/400', 'https://modernfurniture.example.com', '{"monday": "8:00-17:00", "tuesday": "8:00-17:00", "wednesday": "8:00-17:00", "thursday": "8:00-17:00", "friday": "8:00-17:00", "saturday": "closed", "sunday": "closed"}', '#f59e0b', 4.5, 98, 324, 3.2, 96.8, '2024-01-07T00:00:00Z', '2024-01-15T00:00:00Z'),
('user_vendor_004', 'QuickSupply Office Depot', 'LLC', 'REG-456789', 'TAX-012345', '444 Commerce Street', 'Seattle', 'WA', '98101', 'USA', 'Fast delivery of office supplies and equipment nationwide', 'https://picsum.photos/seed/vend004-logo/200', 'https://picsum.photos/seed/vend004-cover/1200/400', 'https://quicksupply.example.com', '{"monday": "7:00-20:00", "tuesday": "7:00-20:00", "wednesday": "7:00-20:00", "thursday": "7:00-20:00", "friday": "7:00-20:00", "saturday": "8:00-18:00", "sunday": "10:00-16:00"}', '#8b5cf6', 4.6, 187, 543, 2.1, 97.9, '2024-01-08T00:00:00Z', '2024-01-15T00:00:00Z'),
('user_vendor_005', 'BuildPro Construction Supplies', 'Corporation', 'REG-567890', 'TAX-123456', '666 Builder Lane', 'Phoenix', 'AZ', '85001', 'USA', 'Professional-grade construction materials and equipment', 'https://picsum.photos/seed/vend005-logo/200', 'https://picsum.photos/seed/vend005-cover/1200/400', 'https://buildpro.example.com', '{"monday": "6:00-18:00", "tuesday": "6:00-18:00", "wednesday": "6:00-18:00", "thursday": "6:00-18:00", "friday": "6:00-18:00", "saturday": "7:00-15:00", "sunday": "closed"}', '#ef4444', 4.8, 134, 401, 2.8, 98.1, '2024-01-09T00:00:00Z', '2024-01-15T00:00:00Z');

-- Seed Vendor Documents
INSERT INTO vendor_documents (document_id, vendor_id, document_type, file_name, file_url, status, verified_by, verified_at, notes, uploaded_at) VALUES
('doc_001', 'user_vendor_001', 'business_license', 'business_license_premium_office.pdf', 'https://example.com/docs/doc_001.pdf', 'verified', 'user_admin_001', '2024-01-06T00:00:00Z', 'All documents in order', '2024-01-05T00:00:00Z'),
('doc_002', 'user_vendor_001', 'tax_certificate', 'tax_cert_premium_office.pdf', 'https://example.com/docs/doc_002.pdf', 'verified', 'user_admin_001', '2024-01-06T00:00:00Z', 'Valid until 2025', '2024-01-05T00:00:00Z'),
('doc_003', 'user_vendor_002', 'business_license', 'business_license_techzone.pdf', 'https://example.com/docs/doc_003.pdf', 'verified', 'user_admin_001', '2024-01-07T00:00:00Z', 'Verified', '2024-01-06T00:00:00Z'),
('doc_004', 'user_vendor_002', 'insurance_certificate', 'insurance_techzone.pdf', 'https://example.com/docs/doc_004.pdf', 'verified', 'user_admin_001', '2024-01-07T00:00:00Z', 'Insurance valid', '2024-01-06T00:00:00Z'),
('doc_005', 'user_vendor_003', 'business_license', 'business_license_furniture.pdf', 'https://example.com/docs/doc_005.pdf', 'pending', NULL, NULL, 'Awaiting review', '2024-01-07T00:00:00Z');

-- Seed Vendor Service Areas
INSERT INTO vendor_service_areas (service_area_id, vendor_id, city_id, city_name, state, delivery_available, delivery_fee, estimated_delivery_days, created_at, updated_at) VALUES
('sa_001', 'user_vendor_001', 'city_dallas', 'Dallas', 'TX', true, 0, 1, '2024-01-05T00:00:00Z', '2024-01-05T00:00:00Z'),
('sa_002', 'user_vendor_001', 'city_houston', 'Houston', 'TX', true, 25.00, 2, '2024-01-05T00:00:00Z', '2024-01-05T00:00:00Z'),
('sa_003', 'user_vendor_001', 'city_austin', 'Austin', 'TX', true, 30.00, 2, '2024-01-05T00:00:00Z', '2024-01-05T00:00:00Z'),
('sa_004', 'user_vendor_002', 'city_sf', 'San Francisco', 'CA', true, 0, 1, '2024-01-06T00:00:00Z', '2024-01-06T00:00:00Z'),
('sa_005', 'user_vendor_002', 'city_sj', 'San Jose', 'CA', true, 15.00, 1, '2024-01-06T00:00:00Z', '2024-01-06T00:00:00Z'),
('sa_006', 'user_vendor_002', 'city_la', 'Los Angeles', 'CA', true, 50.00, 3, '2024-01-06T00:00:00Z', '2024-01-06T00:00:00Z'),
('sa_007', 'user_vendor_003', 'city_miami', 'Miami', 'FL', true, 0, 1, '2024-01-07T00:00:00Z', '2024-01-07T00:00:00Z'),
('sa_008', 'user_vendor_004', 'city_seattle', 'Seattle', 'WA', true, 0, 1, '2024-01-08T00:00:00Z', '2024-01-08T00:00:00Z'),
('sa_009', 'user_vendor_005', 'city_phoenix', 'Phoenix', 'AZ', true, 0, 1, '2024-01-09T00:00:00Z', '2024-01-09T00:00:00Z');

-- Seed Vendor Offers
INSERT INTO vendor_offers (offer_id, vendor_id, product_id, vendor_sku, price, currency, stock_quantity, min_order_quantity, max_order_quantity, lead_time_days, status, internal_notes, created_at, updated_at) VALUES
('offer_001', 'user_vendor_002', 'prod_001', 'DELL-LAT5420-V2', 1299.99, 'USD', 45, 1, 100, 3, 'active', 'Best price in market', '2024-01-06T00:00:00Z', '2024-01-15T00:00:00Z'),
('offer_002', 'user_vendor_002', 'prod_002', 'HP-E243-V2', 249.99, 'USD', 120, 1, 50, 2, 'active', 'Popular model', '2024-01-06T00:00:00Z', '2024-01-15T00:00:00Z'),
('offer_003', 'user_vendor_002', 'prod_003', 'SAMS-C27-V2', 279.99, 'USD', 85, 1, 30, 2, 'active', 'High demand', '2024-01-06T00:00:00Z', '2024-01-15T00:00:00Z'),
('offer_004', 'user_vendor_003', 'prod_004', 'HM-AERON-V3', 1495.00, 'USD', 28, 1, 20, 7, 'active', 'Premium item', '2024-01-07T00:00:00Z', '2024-01-15T00:00:00Z'),
('offer_005', 'user_vendor_003', 'prod_005', 'SC-S1-V3', 599.99, 'USD', 67, 1, 50, 5, 'active', 'Good margin', '2024-01-07T00:00:00Z', '2024-01-15T00:00:00Z'),
('offer_006', 'user_vendor_002', 'prod_006', 'LOGI-MXM3-V2', 99.99, 'USD', 200, 1, 100, 1, 'active', 'Fast mover', '2024-01-06T00:00:00Z', '2024-01-15T00:00:00Z'),
('offer_007', 'user_vendor_004', 'prod_007', 'CAN-MF445-V4', 449.99, 'USD', 55, 1, 25, 3, 'active', 'In stock', '2024-01-08T00:00:00Z', '2024-01-15T00:00:00Z'),
('offer_008', 'user_vendor_001', 'prod_008', 'HP-M404-V1', 399.99, 'USD', 42, 1, 30, 4, 'active', 'Competitive price', '2024-01-05T00:00:00Z', '2024-01-15T00:00:00Z'),
('offer_009', 'user_vendor_003', 'prod_009', 'SC-SDPRO-V3', 899.99, 'USD', 18, 1, 10, 10, 'active', 'Limited stock', '2024-01-07T00:00:00Z', '2024-01-15T00:00:00Z'),
('offer_010', 'user_vendor_002', 'prod_010', 'DELL-U32-V2', 799.99, 'USD', 35, 1, 20, 4, 'active', 'Premium display', '2024-01-06T00:00:00Z', '2024-01-15T00:00:00Z'),
('offer_011', 'user_vendor_001', 'prod_001', 'DELL-LAT5420-V1', 1349.99, 'USD', 32, 1, 50, 5, 'active', 'Alternative supplier', '2024-01-05T00:00:00Z', '2024-01-15T00:00:00Z'),
('offer_012', 'user_vendor_004', 'prod_002', 'HP-E243-V4', 239.99, 'USD', 95, 1, 75, 2, 'active', 'Best price', '2024-01-08T00:00:00Z', '2024-01-15T00:00:00Z');

-- Seed CSV Imports
INSERT INTO csv_imports (import_id, vendor_id, file_name, file_url, total_rows, successful_rows, failed_rows, pending_review_rows, status, error_report_url, column_mapping, created_at, completed_at) VALUES
('import_001', 'user_vendor_001', 'products_january_2024.csv', 'https://example.com/imports/import_001.csv', 150, 142, 5, 3, 'completed', 'https://example.com/imports/import_001_errors.csv', '{"product_name": "A", "price": "B", "stock": "C"}', '2024-01-10T00:00:00Z', '2024-01-10T01:30:00Z'),
('import_002', 'user_vendor_002', 'inventory_update_jan15.csv', 'https://example.com/imports/import_002.csv', 280, 280, 0, 0, 'completed', NULL, '{"sku": "A", "quantity": "B", "price": "C"}', '2024-01-15T00:00:00Z', '2024-01-15T00:45:00Z'),
('import_003', 'user_vendor_003', 'new_products_furniture.csv', 'https://example.com/imports/import_003.csv', 95, 88, 7, 0, 'completed', 'https://example.com/imports/import_003_errors.csv', '{"name": "A", "category": "B", "price": "C"}', '2024-01-12T00:00:00Z', '2024-01-12T00:30:00Z');

-- Seed CSV Import Errors
INSERT INTO csv_import_errors (error_id, import_id, row_number, row_data, error_type, error_message, status, resolved_by, resolution_action, resolved_at, created_at) VALUES
('err_001', 'import_001', 23, '{"product_name": "Unknown Device", "price": "invalid", "stock": "50"}', 'validation_error', 'Invalid price format', 'resolved', 'user_vendor_001', 'corrected_price', '2024-01-10T02:00:00Z', '2024-01-10T01:00:00Z'),
('err_002', 'import_001', 45, '{"product_name": "", "price": "100", "stock": "25"}', 'validation_error', 'Product name is required', 'pending', NULL, NULL, NULL, '2024-01-10T01:00:00Z'),
('err_003', 'import_003', 12, '{"name": "Office Chair", "category": "invalid_cat", "price": "299"}', 'validation_error', 'Category does not exist', 'resolved', 'user_vendor_003', 'assigned_correct_category', '2024-01-12T01:00:00Z', '2024-01-12T00:20:00Z');

-- Seed RFQs
INSERT INTO rfqs (rfq_id, rfq_number, buyer_id, organization_id, product_id, quantity, delivery_address_id, preferred_delivery_date, notes, status, expires_at, closed_reason, closed_at, created_at, updated_at) VALUES
('rfq_001', 'RFQ-2024-0001', 'user_buyer_001', NULL, 'prod_001', 10, 'addr_001', '2024-02-15T00:00:00Z', 'Need urgent delivery for new office setup', 'closed', '2024-01-20T00:00:00Z', 'order_placed', '2024-01-12T00:00:00Z', '2024-01-08T00:00:00Z', '2024-01-12T00:00:00Z'),
('rfq_002', 'RFQ-2024-0002', 'user_buyer_002', 'org_001', 'prod_002', 25, 'addr_003', '2024-02-20T00:00:00Z', 'Looking for best price on monitors for new department', 'closed', '2024-01-25T00:00:00Z', 'order_placed', '2024-01-13T00:00:00Z', '2024-01-09T00:00:00Z', '2024-01-13T00:00:00Z'),
('rfq_003', 'RFQ-2024-0003', 'user_buyer_003', 'org_002', 'prod_004', 50, 'addr_004', '2024-03-01T00:00:00Z', 'Bulk order for new factory office', 'active', '2024-01-30T00:00:00Z', NULL, NULL, '2024-01-10T00:00:00Z', '2024-01-14T00:00:00Z'),
('rfq_004', 'RFQ-2024-0004', 'user_buyer_001', NULL, 'prod_006', 30, 'addr_001', '2024-02-10T00:00:00Z', 'Standard office mice needed', 'closed', '2024-01-22T00:00:00Z', 'order_placed', '2024-01-14T00:00:00Z', '2024-01-11T00:00:00Z', '2024-01-14T00:00:00Z'),
('rfq_005', 'RFQ-2024-0005', 'user_buyer_002', 'org_001', 'prod_010', 15, 'addr_003', '2024-02-25T00:00:00Z', 'Premium monitors for design team', 'active', '2024-02-05T00:00:00Z', NULL, NULL, '2024-01-12T00:00:00Z', '2024-01-15T00:00:00Z'),
('rfq_006', 'RFQ-2024-0006', 'user_buyer_003', 'org_002', 'prod_007', 8, 'addr_004', '2024-02-18T00:00:00Z', 'Multifunction printers for departments', 'active', '2024-01-28T00:00:00Z', NULL, NULL, '2024-01-13T00:00:00Z', '2024-01-14T00:00:00Z'),
('rfq_007', 'RFQ-2024-0007', 'user_buyer_001', NULL, 'prod_009', 5, 'addr_002', '2024-03-05T00:00:00Z', 'Standing desks for home office', 'draft', NULL, NULL, NULL, '2024-01-14T00:00:00Z', '2024-01-14T00:00:00Z');

-- Seed RFQ Attachments
INSERT INTO rfq_attachments (attachment_id, rfq_id, file_name, file_url, file_size, uploaded_at) VALUES
('rfq_att_001', 'rfq_001', 'office_layout.pdf', 'https://example.com/rfq_attachments/rfq_att_001.pdf', 524288, '2024-01-08T00:30:00Z'),
('rfq_att_002', 'rfq_002', 'monitor_specifications.pdf', 'https://example.com/rfq_attachments/rfq_att_002.pdf', 245760, '2024-01-09T01:00:00Z'),
('rfq_att_003', 'rfq_003', 'bulk_order_details.xlsx', 'https://example.com/rfq_attachments/rfq_att_003.xlsx', 102400, '2024-01-10T00:45:00Z');

-- Seed RFQ Vendors
INSERT INTO rfq_vendors (rfq_vendor_id, rfq_id, vendor_id, status, declined_reason, declined_at, notified_at) VALUES
('rfq_v_001', 'rfq_001', 'user_vendor_001', 'responded', NULL, NULL, '2024-01-08T00:05:00Z'),
('rfq_v_002', 'rfq_001', 'user_vendor_002', 'responded', NULL, NULL, '2024-01-08T00:05:00Z'),
('rfq_v_003', 'rfq_002', 'user_vendor_002', 'responded', NULL, NULL, '2024-01-09T00:05:00Z'),
('rfq_v_004', 'rfq_002', 'user_vendor_004', 'responded', NULL, NULL, '2024-01-09T00:05:00Z'),
('rfq_v_005', 'rfq_003', 'user_vendor_003', 'responded', NULL, NULL, '2024-01-10T00:05:00Z'),
('rfq_v_006', 'rfq_004', 'user_vendor_002', 'responded', NULL, NULL, '2024-01-11T00:05:00Z'),
('rfq_v_007', 'rfq_004', 'user_vendor_004', 'declined', 'Out of stock', '2024-01-11T02:00:00Z', '2024-01-11T00:05:00Z'),
('rfq_v_008', 'rfq_005', 'user_vendor_002', 'responded', NULL, NULL, '2024-01-12T00:05:00Z'),
('rfq_v_009', 'rfq_006', 'user_vendor_001', 'responded', NULL, NULL, '2024-01-13T00:05:00Z'),
('rfq_v_010', 'rfq_006', 'user_vendor_004', 'responded', NULL, NULL, '2024-01-13T00:05:00Z');

-- Seed Quotes
INSERT INTO quotes (quote_id, rfq_id, vendor_id, price_per_unit, currency, quantity_available, min_order_quantity, max_order_quantity, delivery_fee, lead_time_days, payment_terms, valid_until, notes, status, accepted_at, created_at, updated_at) VALUES
('quote_001', 'rfq_001', 'user_vendor_001', 1349.99, 'USD', 10, 1, 50, 50.00, 5, 'cod', '2024-01-18T00:00:00Z', 'Can expedite if needed', 'declined', NULL, '2024-01-08T01:00:00Z', '2024-01-10T00:00:00Z'),
('quote_002', 'rfq_001', 'user_vendor_002', 1299.99, 'USD', 10, 1, 100, 0.00, 3, 'cod', '2024-01-18T00:00:00Z', 'Free delivery included. Best price guaranteed.', 'accepted', '2024-01-10T00:00:00Z', '2024-01-08T02:00:00Z', '2024-01-10T00:00:00Z'),
('quote_003', 'rfq_002', 'user_vendor_002', 249.99, 'USD', 25, 1, 50, 25.00, 2, 'cod', '2024-01-23T00:00:00Z', 'Bulk discount applied', 'accepted', '2024-01-11T00:00:00Z', '2024-01-09T03:00:00Z', '2024-01-11T00:00:00Z'),
('quote_004', 'rfq_002', 'user_vendor_004', 239.99, 'USD', 25, 1, 75, 30.00, 2, 'cod', '2024-01-23T00:00:00Z', 'Can match any competitor price', 'declined', NULL, '2024-01-09T04:00:00Z', '2024-01-11T00:00:00Z'),
('quote_005', 'rfq_003', 'user_vendor_003', 1495.00, 'USD', 30, 1, 20, 200.00, 7, 'cod', '2024-01-28T00:00:00Z', 'Premium Herman Miller chairs with full warranty', 'submitted', NULL, '2024-01-10T02:00:00Z', '2024-01-10T02:00:00Z'),
('quote_006', 'rfq_004', 'user_vendor_002', 99.99, 'USD', 30, 1, 100, 15.00, 1, 'cod', '2024-01-20T00:00:00Z', 'Express delivery available', 'accepted', '2024-01-12T00:00:00Z', '2024-01-11T02:00:00Z', '2024-01-12T00:00:00Z'),
('quote_007', 'rfq_005', 'user_vendor_002', 799.99, 'USD', 15, 1, 20, 50.00, 4, 'cod', '2024-02-03T00:00:00Z', '4K premium displays', 'submitted', NULL, '2024-01-12T03:00:00Z', '2024-01-12T03:00:00Z'),
('quote_008', 'rfq_006', 'user_vendor_001', 399.99, 'USD', 8, 1, 30, 0.00, 4, 'cod', '2024-01-26T00:00:00Z', 'Laser printers with warranty', 'submitted', NULL, '2024-01-13T02:00:00Z', '2024-01-13T02:00:00Z'),
('quote_009', 'rfq_006', 'user_vendor_004', 449.99, 'USD', 8, 1, 25, 20.00, 3, 'cod', '2024-01-26T00:00:00Z', 'Canon multifunction printers', 'submitted', NULL, '2024-01-13T03:00:00Z', '2024-01-13T03:00:00Z');

-- Seed Quote Attachments
INSERT INTO quote_attachments (attachment_id, quote_id, file_name, file_url, file_size, uploaded_at) VALUES
('q_att_001', 'quote_002', 'product_datasheet.pdf', 'https://example.com/quote_attachments/q_att_001.pdf', 307200, '2024-01-08T02:15:00Z'),
('q_att_002', 'quote_003', 'warranty_information.pdf', 'https://example.com/quote_attachments/q_att_002.pdf', 204800, '2024-01-09T03:30:00Z'),
('q_att_003', 'quote_005', 'herman_miller_catalog.pdf', 'https://example.com/quote_attachments/q_att_003.pdf', 1048576, '2024-01-10T02:30:00Z');

-- Seed Negotiations
INSERT INTO negotiations (negotiation_id, quote_id, rfq_id, round_number, initiated_by, proposed_price, proposed_quantity, proposed_terms, message, status, created_at) VALUES
('neg_001', 'quote_001', 'rfq_001', 1, 'buyer', 1299.99, NULL, NULL, 'Can you match the other vendor''s price?', 'completed', '2024-01-09T00:00:00Z'),
('neg_002', 'quote_001', 'rfq_001', 2, 'vendor', 1325.00, NULL, 'cod', 'Best we can do is $1325', 'completed', '2024-01-09T02:00:00Z'),
('neg_003', 'quote_004', 'rfq_002', 1, 'buyer', 235.00, NULL, NULL, 'Can you reduce delivery fee?', 'completed', '2024-01-10T00:00:00Z'),
('neg_004', 'quote_004', 'rfq_002', 2, 'vendor', 239.99, NULL, 'Free delivery over $5000', 'Can waive delivery fee for this quantity', 'completed', '2024-01-10T02:00:00Z');

-- Seed RFQ Messages
INSERT INTO rfq_messages (message_id, rfq_id, vendor_id, sender_id, message_text, is_read, read_at, created_at) VALUES
('rfq_msg_001', 'rfq_001', 'user_vendor_002', 'user_buyer_001', 'What is your best delivery timeline?', true, '2024-01-08T03:00:00Z', '2024-01-08T02:30:00Z'),
('rfq_msg_002', 'rfq_001', 'user_vendor_002', 'user_vendor_002', 'We can deliver in 3 business days with free shipping', true, '2024-01-08T04:00:00Z', '2024-01-08T03:30:00Z'),
('rfq_msg_003', 'rfq_002', 'user_vendor_002', 'user_buyer_002', 'Do you offer volume discounts?', true, '2024-01-09T05:00:00Z', '2024-01-09T04:30:00Z'),
('rfq_msg_004', 'rfq_002', 'user_vendor_002', 'user_vendor_002', 'Yes, we''ve applied a 10% bulk discount to the quote', true, '2024-01-09T06:00:00Z', '2024-01-09T05:30:00Z'),
('rfq_msg_005', 'rfq_003', 'user_vendor_003', 'user_buyer_003', 'Can you provide installation services?', true, '2024-01-10T03:00:00Z', '2024-01-10T02:30:00Z');

-- Seed RFQ Message Attachments
INSERT INTO rfq_message_attachments (attachment_id, message_id, file_name, file_url, file_size, uploaded_at) VALUES
('rfq_m_att_001', 'rfq_msg_002', 'shipping_schedule.pdf', 'https://example.com/rfq_msg_attachments/rfq_m_att_001.pdf', 153600, '2024-01-08T03:35:00Z'),
('rfq_m_att_002', 'rfq_msg_004', 'discount_breakdown.xlsx', 'https://example.com/rfq_msg_attachments/rfq_m_att_002.xlsx', 81920, '2024-01-09T05:35:00Z');

-- Seed Orders
INSERT INTO orders (order_id, order_number, rfq_id, quote_id, buyer_id, vendor_id, organization_id, product_id, quantity, unit_price, currency, subtotal, delivery_fee, total_amount, delivery_address_id, expected_delivery_date, status, payment_method, vendor_declined_reason, cancelled_by, cancellation_reason, cancelled_at, created_at, updated_at) VALUES
('order_001', 'ORD-2024-0001', 'rfq_001', 'quote_002', 'user_buyer_001', 'user_vendor_002', NULL, 'prod_001', 10, 1299.99, 'USD', 12999.90, 0.00, 12999.90, 'addr_001', '2024-01-18T00:00:00Z', 'delivered', 'cod', NULL, NULL, NULL, NULL, '2024-01-10T00:00:00Z', '2024-01-18T00:00:00Z'),
('order_002', 'ORD-2024-0002', 'rfq_002', 'quote_003', 'user_buyer_002', 'user_vendor_002', 'org_001', 'prod_002', 25, 249.99, 'USD', 6249.75, 25.00, 6274.75, 'addr_003', '2024-01-20T00:00:00Z', 'delivered', 'cod', NULL, NULL, NULL, NULL, '2024-01-11T00:00:00Z', '2024-01-20T00:00:00Z'),
('order_003', 'ORD-2024-0003', 'rfq_004', 'quote_006', 'user_buyer_001', 'user_vendor_002', NULL, 'prod_006', 30, 99.99, 'USD', 2999.70, 15.00, 3014.70, 'addr_001', '2024-01-15T00:00:00Z', 'delivered', 'cod', NULL, NULL, NULL, NULL, '2024-01-12T00:00:00Z', '2024-01-15T00:00:00Z'),
('order_004', 'ORD-2024-0004', 'rfq_005', 'quote_007', 'user_buyer_002', 'user_vendor_002', 'org_001', 'prod_010', 15, 799.99, 'USD', 11999.85, 50.00, 12049.85, 'addr_003', '2024-02-01T00:00:00Z', 'in_transit', 'cod', NULL, NULL, NULL, NULL, '2024-01-13T00:00:00Z', '2024-01-16T00:00:00Z'),
('order_005', 'ORD-2024-0005', 'rfq_006', 'quote_008', 'user_buyer_003', 'user_vendor_001', 'org_002', 'prod_008', 8, 399.99, 'USD', 3199.92, 0.00, 3199.92, 'addr_004', '2024-01-25T00:00:00Z', 'confirmed', 'cod', NULL, NULL, NULL, NULL, '2024-01-14T00:00:00Z', '2024-01-14T00:00:00Z');

-- Seed Order Status History
INSERT INTO order_status_history (history_id, order_id, previous_status, new_status, changed_by, notes, created_at) VALUES
('hist_001', 'order_001', NULL, 'pending_vendor_confirmation', 'user_buyer_001', 'Order created', '2024-01-10T00:00:00Z'),
('hist_002', 'order_001', 'pending_vendor_confirmation', 'confirmed', 'user_vendor_002', 'Order confirmed by vendor', '2024-01-10T02:00:00Z'),
('hist_003', 'order_001', 'confirmed', 'preparing', 'user_vendor_002', 'Started preparing order', '2024-01-11T00:00:00Z'),
('hist_004', 'order_001', 'preparing', 'dispatched', 'user_vendor_002', 'Order shipped', '2024-01-13T00:00:00Z'),
('hist_005', 'order_001', 'dispatched', 'in_transit', 'user_vendor_002', 'Out for delivery', '2024-01-17T00:00:00Z'),
('hist_006', 'order_001', 'in_transit', 'delivered', 'user_vendor_002', 'Successfully delivered', '2024-01-18T00:00:00Z'),
('hist_007', 'order_002', NULL, 'pending_vendor_confirmation', 'user_buyer_002', 'Order created', '2024-01-11T00:00:00Z'),
('hist_008', 'order_002', 'pending_vendor_confirmation', 'confirmed', 'user_vendor_002', 'Order confirmed', '2024-01-11T03:00:00Z'),
('hist_009', 'order_002', 'confirmed', 'preparing', 'user_vendor_002', 'Processing order', '2024-01-12T00:00:00Z'),
('hist_010', 'order_002', 'preparing', 'dispatched', 'user_vendor_002', 'Dispatched', '2024-01-15T00:00:00Z'),
('hist_011', 'order_002', 'dispatched', 'in_transit', 'user_vendor_002', 'In transit', '2024-01-19T00:00:00Z'),
('hist_012', 'order_002', 'in_transit', 'delivered', 'user_vendor_002', 'Delivered successfully', '2024-01-20T00:00:00Z'),
('hist_013', 'order_003', NULL, 'pending_vendor_confirmation', 'user_buyer_001', 'Order created', '2024-01-12T00:00:00Z'),
('hist_014', 'order_003', 'pending_vendor_confirmation', 'confirmed', 'user_vendor_002', 'Confirmed', '2024-01-12T01:00:00Z'),
('hist_015', 'order_003', 'confirmed', 'dispatched', 'user_vendor_002', 'Same day dispatch', '2024-01-12T10:00:00Z'),
('hist_016', 'order_003', 'dispatched', 'delivered', 'user_vendor_002', 'Quick delivery', '2024-01-15T00:00:00Z'),
('hist_017', 'order_004', NULL, 'pending_vendor_confirmation', 'user_buyer_002', 'Order placed', '2024-01-13T00:00:00Z'),
('hist_018', 'order_004', 'pending_vendor_confirmation', 'confirmed', 'user_vendor_002', 'Confirmed', '2024-01-13T02:00:00Z'),
('hist_019', 'order_004', 'confirmed', 'dispatched', 'user_vendor_002', 'Dispatched', '2024-01-14T00:00:00Z'),
('hist_020', 'order_004', 'dispatched', 'in_transit', 'user_vendor_002', 'On the way', '2024-01-16T00:00:00Z');

-- Seed Delivery Details
INSERT INTO delivery_details (delivery_id, order_id, driver_name, driver_contact, vehicle_number, estimated_delivery_time, actual_delivery_time, recipient_name, signature_url, delivery_photo_url, delivery_notes, marked_dispatched_at, marked_delivered_at) VALUES
('del_001', 'order_001', 'Mike Driver', '+1234567800', 'ABC-123', '2024-01-18T14:00:00Z', '2024-01-18T13:45:00Z', 'John Buyer', 'https://picsum.photos/seed/sign001/300/100', 'https://picsum.photos/seed/deliv001/600', 'Delivered to front door as requested', '2024-01-13T00:00:00Z', '2024-01-18T13:45:00Z'),
('del_002', 'order_002', 'Sarah Transport', '+1234567801', 'XYZ-456', '2024-01-20T10:00:00Z', '2024-01-20T09:30:00Z', 'Sarah Procurement', 'https://picsum.photos/seed/sign002/300/100', 'https://picsum.photos/seed/deliv002/600', 'Delivered to warehouse loading dock', '2024-01-15T00:00:00Z', '2024-01-20T09:30:00Z'),
('del_003', 'order_003', 'Tom Delivery', '+1234567802', 'DEF-789', '2024-01-15T16:00:00Z', '2024-01-15T15:45:00Z', 'John Buyer', 'https://picsum.photos/seed/sign003/300/100', 'https://picsum.photos/seed/deliv003/600', 'Quick express delivery', '2024-01-12T10:00:00Z', '2024-01-15T15:45:00Z'),
('del_004', 'order_004', 'Lisa Courier', '+1234567803', 'GHI-012', '2024-02-01T11:00:00Z', NULL, NULL, NULL, NULL, NULL, '2024-01-14T00:00:00Z', NULL);

-- Seed Cash Collections
INSERT INTO cash_collections (collection_id, order_id, amount_collected, collected_by, collection_timestamp, notes, receipt_number, reconciliation_status, reconciled_at, payout_date, payout_reference, created_at) VALUES
('cash_001', 'order_001', 12999.90, 'Mike Driver', '2024-01-18T13:45:00Z', 'Payment received in full', 'RCP-2024-0001', 'completed', '2024-01-19T00:00:00Z', '2024-01-22T00:00:00Z', 'PAYOUT-VND002-001', '2024-01-18T13:45:00Z'),
('cash_002', 'order_002', 6274.75, 'Sarah Transport', '2024-01-20T09:30:00Z', 'Cash payment collected', 'RCP-2024-0002', 'completed', '2024-01-21T00:00:00Z', '2024-01-24T00:00:00Z', 'PAYOUT-VND002-002', '2024-01-20T09:30:00Z'),
('cash_003', 'order_003', 3014.70, 'Tom Delivery', '2024-01-15T15:45:00Z', 'Payment received', 'RCP-2024-0003', 'completed', '2024-01-16T00:00:00Z', '2024-01-19T00:00:00Z', 'PAYOUT-VND002-003', '2024-01-15T15:45:00Z');

-- Seed Order Documents
INSERT INTO order_documents (document_id, order_id, document_type, file_name, file_url, uploaded_by, uploaded_at) VALUES
('ord_doc_001', 'order_001', 'invoice', 'invoice_ORD-2024-0001.pdf', 'https://example.com/order_docs/ord_doc_001.pdf', 'user_vendor_002', '2024-01-10T02:30:00Z'),
('ord_doc_002', 'order_001', 'delivery_note', 'delivery_ORD-2024-0001.pdf', 'https://example.com/order_docs/ord_doc_002.pdf', 'user_vendor_002', '2024-01-13T00:30:00Z'),
('ord_doc_003', 'order_002', 'invoice', 'invoice_ORD-2024-0002.pdf', 'https://example.com/order_docs/ord_doc_003.pdf', 'user_vendor_002', '2024-01-11T03:30:00Z'),
('ord_doc_004', 'order_002', 'packing_list', 'packing_ORD-2024-0002.pdf', 'https://example.com/order_docs/ord_doc_004.pdf', 'user_vendor_002', '2024-01-15T00:30:00Z');

-- Seed Order Messages
INSERT INTO order_messages (message_id, order_id, sender_id, message_text, is_read, read_at, created_at) VALUES
('ord_msg_001', 'order_001', 'user_buyer_001', 'When will this be shipped?', true, '2024-01-11T01:00:00Z', '2024-01-11T00:30:00Z'),
('ord_msg_002', 'order_001', 'user_vendor_002', 'We''re preparing your order and it will ship tomorrow', true, '2024-01-11T02:00:00Z', '2024-01-11T01:30:00Z'),
('ord_msg_003', 'order_002', 'user_buyer_002', 'Please ensure delivery to loading dock B', true, '2024-01-14T00:00:00Z', '2024-01-13T23:30:00Z'),
('ord_msg_004', 'order_002', 'user_vendor_002', 'Noted. Driver has been informed', true, '2024-01-14T01:00:00Z', '2024-01-14T00:30:00Z');

-- Seed Order Message Attachments
INSERT INTO order_message_attachments (attachment_id, message_id, file_name, file_url, file_size, uploaded_at) VALUES
('ord_m_att_001', 'ord_msg_003', 'warehouse_map.pdf', 'https://example.com/order_msg_attachments/ord_m_att_001.pdf', 204800, '2024-01-13T23:35:00Z');

-- Seed Disputes
INSERT INTO disputes (dispute_id, order_id, raised_by, issue_type, description, preferred_resolution, status, assigned_to, resolution_decision, resolution_notes, resolution_action, resolved_by, resolved_at, closed_at, created_at, updated_at) VALUES
('dispute_001', 'order_001', 'user_buyer_001', 'quality_issue', 'One laptop arrived with a damaged screen', 'replacement', 'resolved', 'user_admin_001', 'replace', 'Replacement unit shipped', 'replacement_shipped', 'user_admin_001', '2024-01-19T00:00:00Z', '2024-01-21T00:00:00Z', '2024-01-18T15:00:00Z', '2024-01-21T00:00:00Z');

-- Seed Dispute Evidence
INSERT INTO dispute_evidence (evidence_id, dispute_id, uploaded_by, file_name, file_url, file_type, uploaded_at) VALUES
('disp_ev_001', 'dispute_001', 'user_buyer_001', 'damaged_screen_photo1.jpg', 'https://picsum.photos/seed/dispute001-1/800', 'image', '2024-01-18T15:15:00Z'),
('disp_ev_002', 'dispute_001', 'user_buyer_001', 'damaged_screen_photo2.jpg', 'https://picsum.photos/seed/dispute001-2/800', 'image', '2024-01-18T15:16:00Z'),
('disp_ev_003', 'dispute_001', 'user_buyer_001', 'unboxing_video.mp4', 'https://example.com/dispute_evidence/disp_ev_003.mp4', 'video', '2024-01-18T15:20:00Z');

-- Seed Dispute Messages
INSERT INTO dispute_messages (message_id, dispute_id, sender_id, recipient_ids, message_text, created_at) VALUES
('disp_msg_001', 'dispute_001', 'user_buyer_001', '["user_vendor_002", "user_admin_001"]', 'The screen has visible cracks. This must have happened during shipping.', '2024-01-18T15:00:00Z'),
('disp_msg_002', 'dispute_001', 'user_vendor_002', '["user_buyer_001", "user_admin_001"]', 'We apologize for this. We''ll arrange a replacement immediately.', '2024-01-18T16:00:00Z'),
('disp_msg_003', 'dispute_001', 'user_admin_001', '["user_buyer_001", "user_vendor_002"]', 'Replacement approved. New unit will ship within 24 hours.', '2024-01-19T00:00:00Z');

-- Seed Reviews
INSERT INTO reviews (review_id, order_id, buyer_id, vendor_id, overall_rating, product_quality_rating, delivery_rating, communication_rating, pricing_rating, review_text, is_anonymous, helpful_count, is_verified_purchase, vendor_response, vendor_response_at, status, hidden_reason, hidden_by, hidden_at, created_at, updated_at) VALUES
('review_001', 'order_001', 'user_buyer_001', 'user_vendor_002', 5, 5, 5, 5, 5, 'Excellent service! Fast delivery and great quality laptops. Despite the one damaged unit, the vendor''s quick response to replace it was impressive. Highly recommend.', false, 12, true, 'Thank you for your feedback! We''re glad we could resolve the issue quickly.', '2024-01-22T00:00:00Z', 'published', NULL, NULL, NULL, '2024-01-21T00:00:00Z', '2024-01-22T00:00:00Z'),
('review_002', 'order_002', 'user_buyer_002', 'user_vendor_002', 5, 5, 5, 5, 5, 'Perfect for our office needs. All 25 monitors arrived in excellent condition. Vendor was professional throughout.', false, 8, true, 'We appreciate your business!', '2024-01-21T00:00:00Z', 'published', NULL, NULL, NULL, '2024-01-21T00:00:00Z', '2024-01-21T00:00:00Z'),
('review_003', 'order_003', 'user_buyer_001', 'user_vendor_002', 4, 5, 5, 4, 4, 'Great mice, fast delivery. Good value for the price.', false, 3, true, NULL, NULL, 'published', NULL, NULL, NULL, '2024-01-16T00:00:00Z', '2024-01-16T00:00:00Z');

-- Seed Review Photos
INSERT INTO review_photos (photo_id, review_id, photo_url, uploaded_at) VALUES
('rev_photo_001', 'review_001', 'https://picsum.photos/seed/review001-1/600', '2024-01-21T00:15:00Z'),
('rev_photo_002', 'review_001', 'https://picsum.photos/seed/review001-2/600', '2024-01-21T00:16:00Z'),
('rev_photo_003', 'review_002', 'https://picsum.photos/seed/review002-1/600', '2024-01-21T00:15:00Z');

-- Seed Review Helpfulness
INSERT INTO review_helpfulness (helpfulness_id, review_id, user_id, created_at) VALUES
('help_001', 'review_001', 'user_buyer_002', '2024-01-22T00:00:00Z'),
('help_002', 'review_001', 'user_buyer_003', '2024-01-22T01:00:00Z'),
('help_003', 'review_002', 'user_buyer_001', '2024-01-22T00:00:00Z');

-- Seed Notifications
INSERT INTO notifications (notification_id, user_id, notification_type, category, title, message, link_url, entity_type, entity_id, is_read, read_at, is_archived, archived_at, created_at) VALUES
('notif_001', 'user_buyer_001', 'order_confirmed', 'orders', 'Order Confirmed', 'Your order ORD-2024-0001 has been confirmed by the vendor', '/orders/order_001', 'order', 'order_001', true, '2024-01-10T02:30:00Z', false, NULL, '2024-01-10T02:00:00Z'),
('notif_002', 'user_buyer_001', 'order_dispatched', 'orders', 'Order Dispatched', 'Your order ORD-2024-0001 has been dispatched', '/orders/order_001', 'order', 'order_001', true, '2024-01-13T01:00:00Z', false, NULL, '2024-01-13T00:00:00Z'),
('notif_003', 'user_buyer_001', 'order_delivered', 'orders', 'Order Delivered', 'Your order ORD-2024-0001 has been delivered', '/orders/order_001', 'order', 'order_001', true, '2024-01-18T14:00:00Z', false, NULL, '2024-01-18T13:45:00Z'),
('notif_004', 'user_vendor_002', 'new_rfq', 'rfqs', 'New Quote Request', 'You have received a new quote request RFQ-2024-0001', '/rfqs/rfq_001', 'rfq', 'rfq_001', true, '2024-01-08T00:10:00Z', false, NULL, '2024-01-08T00:05:00Z'),
('notif_005', 'user_vendor_002', 'quote_accepted', 'quotes', 'Quote Accepted', 'Your quote for RFQ-2024-0001 has been accepted', '/quotes/quote_002', 'quote', 'quote_002', true, '2024-01-10T00:30:00Z', false, NULL, '2024-01-10T00:00:00Z'),
('notif_006', 'user_buyer_002', 'quote_received', 'quotes', 'New Quote Received', 'You have received a new quote for RFQ-2024-0002', '/rfqs/rfq_002/quotes', 'rfq', 'rfq_002', true, '2024-01-09T03:30:00Z', false, NULL, '2024-01-09T03:00:00Z'),
('notif_007', 'user_buyer_001', 'dispute_resolved', 'disputes', 'Dispute Resolved', 'Your dispute for order ORD-2024-0001 has been resolved', '/disputes/dispute_001', 'dispute', 'dispute_001', true, '2024-01-19T01:00:00Z', false, NULL, '2024-01-19T00:00:00Z');

-- Seed Notification Preferences
INSERT INTO notification_preferences (preference_id, user_id, email_notifications, in_app_notifications, sms_notifications, quiet_hours_start, quiet_hours_end, digest_frequency, updated_at) VALUES
('notif_pref_001', 'user_buyer_001', '{"orders": true, "quotes": true, "messages": true, "disputes": true}', '{"orders": true, "quotes": true, "messages": true, "disputes": true}', '{"orders": true, "quotes": false, "messages": false, "disputes": true}', '22:00', '08:00', 'daily', '2024-01-02T00:00:00Z'),
('notif_pref_002', 'user_vendor_002', '{"rfqs": true, "orders": true, "reviews": true, "messages": true}', '{"rfqs": true, "orders": true, "reviews": true, "messages": true}', '{"rfqs": true, "orders": true, "reviews": false, "messages": false}', '23:00', '07:00', 'immediate', '2024-01-06T00:00:00Z');

-- Seed Saved Searches
INSERT INTO saved_searches (saved_search_id, user_id, search_name, search_query, filters, sort_by, alerts_enabled, alert_frequency, last_executed_at, results_count, created_at, updated_at) VALUES
('search_001', 'user_buyer_001', 'Dell Laptops under $1500', 'Dell laptop', '{"category": "cat_005", "price_max": 1500, "brand": "brand_001"}', 'price_asc', true, 'daily', '2024-01-15T00:00:00Z', 5, '2024-01-08T00:00:00Z', '2024-01-15T00:00:00Z'),
('search_002', 'user_buyer_002', 'Office Monitors 24-27 inch', 'monitor', '{"category": "cat_006", "size_min": 24, "size_max": 27}', 'rating_desc', true, 'weekly', '2024-01-14T00:00:00Z', 12, '2024-01-09T00:00:00Z', '2024-01-14T00:00:00Z'),
('search_003', 'user_buyer_003', 'Ergonomic Chairs', 'ergonomic chair', '{"category": "cat_007"}', 'popularity', false, NULL, '2024-01-13T00:00:00Z', 8, '2024-01-10T00:00:00Z', '2024-01-13T00:00:00Z');

-- Seed Favorite Products
INSERT INTO favorite_products (favorite_id, user_id, product_id, price_alert_enabled, last_known_price, created_at) VALUES
('fav_prod_001', 'user_buyer_001', 'prod_001', true, 1299.99, '2024-01-08T00:00:00Z'),
('fav_prod_002', 'user_buyer_001', 'prod_004', true, 1495.00, '2024-01-09T00:00:00Z'),
('fav_prod_003', 'user_buyer_002', 'prod_002', false, 249.99, '2024-01-09T00:00:00Z'),
('fav_prod_004', 'user_buyer_002', 'prod_010', true, 799.99, '2024-01-12T00:00:00Z'),
('fav_prod_005', 'user_buyer_003', 'prod_005', false, 599.99, '2024-01-10T00:00:00Z');

-- Seed Favorite Vendors
INSERT INTO favorite_vendors (favorite_id, user_id, vendor_id, created_at) VALUES
('fav_vend_001', 'user_buyer_001', 'user_vendor_002', '2024-01-10T00:00:00Z'),
('fav_vend_002', 'user_buyer_002', 'user_vendor_002', '2024-01-11T00:00:00Z'),
('fav_vend_003', 'user_buyer_003', 'user_vendor_003', '2024-01-10T00:00:00Z'),
('fav_vend_004', 'user_buyer_001', 'user_vendor_003', '2024-01-12T00:00:00Z');

-- Seed Recently Viewed Products
INSERT INTO recently_viewed_products (view_id, user_id, product_id, viewed_at) VALUES
('view_001', 'user_buyer_001', 'prod_001', '2024-01-15T10:00:00Z'),
('view_002', 'user_buyer_001', 'prod_002', '2024-01-15T10:05:00Z'),
('view_003', 'user_buyer_001', 'prod_006', '2024-01-15T10:10:00Z'),
('view_004', 'user_buyer_002', 'prod_010', '2024-01-15T09:00:00Z'),
('view_005', 'user_buyer_002', 'prod_002', '2024-01-15T09:15:00Z'),
('view_006', 'user_buyer_003', 'prod_004', '2024-01-14T16:00:00Z'),
('view_007', 'user_buyer_003', 'prod_005', '2024-01-14T16:10:00Z');

-- Seed User Preferences
INSERT INTO user_preferences (preference_id, user_id, preferred_currency, language, rtl_enabled, timezone, date_format, updated_at) VALUES
('pref_001', 'user_buyer_001', 'USD', 'en', false, 'America/Los_Angeles', 'MM/DD/YYYY', '2024-01-02T00:00:00Z'),
('pref_002', 'user_buyer_002', 'USD', 'en', false, 'America/Chicago', 'MM/DD/YYYY', '2024-01-03T00:00:00Z'),
('pref_003', 'user_vendor_002', 'USD', 'en', false, 'America/Los_Angeles', 'MM/DD/YYYY', '2024-01-06T00:00:00Z');

-- Seed API Keys
INSERT INTO api_keys (api_key_id, vendor_id, key_name, api_key, permissions, expires_at, last_used_at, is_active, created_at) VALUES
('api_key_001', 'user_vendor_002', 'Production API Key', 'sk_live_abc123xyz789', '["read_products", "update_inventory", "read_orders", "update_orders"]', '2025-01-06T00:00:00Z', '2024-01-15T00:00:00Z', true, '2024-01-06T00:00:00Z'),
('api_key_002', 'user_vendor_001', 'Inventory Management', 'sk_live_def456uvw012', '["read_products", "update_inventory"]', '2025-01-05T00:00:00Z', '2024-01-14T00:00:00Z', true, '2024-01-05T00:00:00Z');

-- Seed Webhooks
INSERT INTO webhooks (webhook_id, vendor_id, endpoint_url, secret_key, events, is_active, created_at, updated_at) VALUES
('webhook_001', 'user_vendor_002', 'https://techzone.example.com/webhooks/orders', 'whsec_abc123xyz789', '["order.created", "order.confirmed", "order.cancelled"]', true, '2024-01-06T00:00:00Z', '2024-01-06T00:00:00Z'),
('webhook_002', 'user_vendor_001', 'https://premiumoffice.example.com/api/webhooks', 'whsec_def456uvw012', '["order.created", "rfq.received"]', true, '2024-01-05T00:00:00Z', '2024-01-05T00:00:00Z');

-- Seed Webhook Logs
INSERT INTO webhook_logs (log_id, webhook_id, event_type, payload, response_status, response_body, retry_count, status, created_at) VALUES
('wh_log_001', 'webhook_001', 'order.created', '{"order_id": "order_001", "order_number": "ORD-2024-0001", "total_amount": 12999.90}', 200, '{"success": true}', 0, 'success', '2024-01-10T00:00:00Z'),
('wh_log_002', 'webhook_001', 'order.confirmed', '{"order_id": "order_001", "order_number": "ORD-2024-0001"}', 200, '{"success": true}', 0, 'success', '2024-01-10T02:00:00Z'),
('wh_log_003', 'webhook_002', 'rfq.received', '{"rfq_id": "rfq_001", "rfq_number": "RFQ-2024-0001"}', 500, '{"error": "Internal server error"}', 3, 'failed', '2024-01-08T00:05:00Z');

-- Seed Audit Logs
INSERT INTO audit_logs (log_id, user_id, action_type, entity_type, entity_id, old_value, new_value, ip_address, user_agent, details, created_at) VALUES
('audit_001', 'user_admin_001', 'create', 'user', 'user_vendor_001', NULL, '{"email": "vendor1@supplies.com", "role": "vendor"}', '192.168.1.1', 'Mozilla/5.0', '{"action": "User created"}', '2024-01-05T00:00:00Z'),
('audit_002', 'user_vendor_002', 'update', 'vendor_offer', 'offer_001', '{"price": 1349.99}', '{"price": 1299.99}', '192.168.1.101', 'Chrome/120.0', '{"action": "Price updated"}', '2024-01-15T00:00:00Z'),
('audit_003', 'user_buyer_001', 'create', 'order', 'order_001', NULL, '{"order_number": "ORD-2024-0001", "total": 12999.90}', '192.168.1.100', 'Safari/17.0', '{"action": "Order placed"}', '2024-01-10T00:00:00Z');

-- Seed System Settings
INSERT INTO system_settings (setting_key, setting_value, setting_type, description, updated_by, updated_at) VALUES
('platform_commission_rate', '5', 'number', 'Platform commission percentage on orders', 'user_admin_001', '2024-01-01T00:00:00Z'),
('max_rfq_vendors', '10', 'number', 'Maximum number of vendors that can be invited per RFQ', 'user_admin_001', '2024-01-01T00:00:00Z'),
('quote_validity_days', '7', 'number', 'Default validity period for quotes in days', 'user_admin_001', '2024-01-01T00:00:00Z'),
('maintenance_mode', 'false', 'boolean', 'Enable maintenance mode', 'user_admin_001', '2024-01-15T00:00:00Z'),
('featured_categories', '["cat_001", "cat_002", "cat_003"]', 'json', 'Featured categories on homepage', 'user_admin_001', '2024-01-10T00:00:00Z');

-- Seed Currencies
INSERT INTO currencies (currency_code, currency_name, symbol, exchange_rate_to_base, is_active, last_updated) VALUES
('USD', 'US Dollar', '$', 1.00, true, '2024-01-15T00:00:00Z'),
('EUR', 'Euro', '€', 0.92, true, '2024-01-15T00:00:00Z'),
('GBP', 'British Pound', '£', 0.79, true, '2024-01-15T00:00:00Z'),
('CAD', 'Canadian Dollar', 'C$', 1.35, true, '2024-01-15T00:00:00Z'),
('AUD', 'Australian Dollar', 'A$', 1.52, true, '2024-01-15T00:00:00Z');

-- Seed Cities
INSERT INTO cities (city_id, city_name, state, country, latitude, longitude, is_active) VALUES
('city_dallas', 'Dallas', 'TX', 'USA', 32.7767, -96.7970, true),
('city_houston', 'Houston', 'TX', 'USA', 29.7604, -95.3698, true),
('city_austin', 'Austin', 'TX', 'USA', 30.2672, -97.7431, true),
('city_sf', 'San Francisco', 'CA', 'USA', 37.7749, -122.4194, true),
('city_sj', 'San Jose', 'CA', 'USA', 37.3382, -121.8863, true),
('city_la', 'Los Angeles', 'CA', 'USA', 34.0522, -118.2437, true),
('city_miami', 'Miami', 'FL', 'USA', 25.7617, -80.1918, true),
('city_seattle', 'Seattle', 'WA', 'USA', 47.6062, -122.3321, true),
('city_phoenix', 'Phoenix', 'AZ', 'USA', 33.4484, -112.0740, true),
('city_chicago', 'Chicago', 'IL', 'USA', 41.8781, -87.6298, true),
('city_boston', 'Boston', 'MA', 'USA', 42.3601, -71.0589, true),
('city_detroit', 'Detroit', 'MI', 'USA', 42.3314, -83.0458, true);

-- Seed Product Merges
INSERT INTO product_merges (merge_id, primary_product_id, merged_product_ids, merged_by, merged_at, is_reversed, reversed_by, reversed_at) VALUES
('merge_001', 'prod_001', '["prod_001_duplicate_1", "prod_001_duplicate_2"]', 'user_admin_001', '2024-01-10T00:00:00Z', false, NULL, NULL);

-- Seed Announcements
INSERT INTO announcements (announcement_id, title, message, target_audience, display_type, start_date, end_date, is_active, created_by, created_at, updated_at) VALUES
('announce_001', 'Platform Maintenance Scheduled', 'We will be performing scheduled maintenance on January 20th from 2 AM to 4 AM EST. The platform will be temporarily unavailable during this time.', 'all', 'banner', '2024-01-15T00:00:00Z', '2024-01-20T00:00:00Z', true, 'user_admin_001', '2024-01-15T00:00:00Z', '2024-01-15T00:00:00Z'),
('announce_002', 'New Feature: Bulk Import', 'Vendors can now import products in bulk using CSV files. Check out the new import feature in your dashboard!', 'vendors', 'modal', '2024-01-10T00:00:00Z', '2024-01-25T00:00:00Z', true, 'user_admin_001', '2024-01-10T00:00:00Z', '2024-01-10T00:00:00Z'),
('announce_003', 'Welcome Bonus for New Buyers', 'Get 10% off your first order! Use code WELCOME10 at checkout.', 'buyers', 'notification', '2024-01-01T00:00:00Z', '2024-02-01T00:00:00Z', true, 'user_admin_001', '2024-01-01T00:00:00Z', '2024-01-01T00:00:00Z');

-- Seed Price History
INSERT INTO price_history (history_id, offer_id, product_id, vendor_id, price, currency, recorded_at) VALUES
('price_hist_001', 'offer_001', 'prod_001', 'user_vendor_002', 1349.99, 'USD', '2024-01-06T00:00:00Z'),
('price_hist_002', 'offer_001', 'prod_001', 'user_vendor_002', 1329.99, 'USD', '2024-01-10T00:00:00Z'),
('price_hist_003', 'offer_001', 'prod_001', 'user_vendor_002', 1299.99, 'USD', '2024-01-15T00:00:00Z'),
('price_hist_004', 'offer_002', 'prod_002', 'user_vendor_002', 269.99, 'USD', '2024-01-06T00:00:00Z'),
('price_hist_005', 'offer_002', 'prod_002', 'user_vendor_002', 249.99, 'USD', '2024-01-12T00:00:00Z'),
('price_hist_006', 'offer_003', 'prod_003', 'user_vendor_002', 299.99, 'USD', '2024-01-06T00:00:00Z'),
('price_hist_007', 'offer_003', 'prod_003', 'user_vendor_002', 279.99, 'USD', '2024-01-13T00:00:00Z');

-- Seed Email Logs
INSERT INTO email_logs (email_log_id, recipient_email, email_type, subject, status, sent_at, delivered_at, opened_at, clicked_at, error_message, created_at) VALUES
('email_001', 'john.buyer@email.com', 'order_confirmation', 'Order Confirmation - ORD-2024-0001', 'delivered', '2024-01-10T00:01:00Z', '2024-01-10T00:01:30Z', '2024-01-10T00:15:00Z', '2024-01-10T00:20:00Z', NULL, '2024-01-10T00:00:00Z'),
('email_002', 'vendor1@supplies.com', 'new_rfq', 'New Quote Request - RFQ-2024-0001', 'delivered', '2024-01-08T00:06:00Z', '2024-01-08T00:06:20Z', '2024-01-08T00:30:00Z', NULL, NULL, '2024-01-08T00:05:00Z'),
('email_003', 'sarah.procurement@email.com', 'quote_received', 'New Quote for RFQ-2024-0002', 'delivered', '2024-01-09T03:01:00Z', '2024-01-09T03:01:15Z', '2024-01-09T08:00:00Z', NULL, NULL, '2024-01-09T03:00:00Z'),
('email_004', 'john.buyer@email.com', 'order_dispatched', 'Your Order Has Been Shipped - ORD-2024-0001', 'delivered', '2024-01-13T00:01:00Z', '2024-01-13T00:01:25Z', '2024-01-13T01:00:00Z', NULL, NULL, '2024-01-13T00:00:00Z'),
('email_005', 'newuser@example.com', 'magic_link', 'Your Login Link', 'failed', NULL, NULL, NULL, NULL, 'Email address not found', '2024-01-15T10:00:00Z');

-- Seed SMS Logs
INSERT INTO sms_logs (sms_log_id, recipient_phone, sms_type, message, status, sent_at, delivered_at, error_message, created_at) VALUES
('sms_001', '+1234567891', 'order_confirmation', 'Your order ORD-2024-0001 has been confirmed. Total: $12999.90', 'delivered', '2024-01-10T00:01:00Z', '2024-01-10T00:01:05Z', NULL, '2024-01-10T00:00:00Z'),
('sms_002', '+1234567891', 'order_dispatched', 'Your order ORD-2024-0001 has been dispatched and is on its way!', 'delivered', '2024-01-13T00:01:00Z', '2024-01-13T00:01:08Z', NULL, '2024-01-13T00:00:00Z'),
('sms_003', '+1234567892', 'quote_received', 'New quote received for RFQ-2024-0002. Check your dashboard.', 'delivered', '2024-01-09T03:01:00Z', '2024-01-09T03:01:12Z', NULL, '2024-01-09T03:00:00Z'),
('sms_004', '+9999999999', 'magic_link', 'Your verification code: 123456', 'failed', NULL, NULL, 'Invalid phone number', '2024-01-15T00:00:00Z');