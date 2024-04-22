-- use database
USE new_data ;

-- ****creating views****

-- reward_history 
CREATE VIEW reward_history AS
    SELECT 
        rh.user_id,
        u.first_name AS user_name,
        u.mobile,
        u.email,
        rh.store_admin,
        rh.store_id,
        rh.reward_id,
        rh.type,
        rh.pointe AS points,
        rh.added_or_removed,
        rh.created_at
    FROM
        tbl_reward_history AS rh
            LEFT JOIN
        users AS u ON rh.user_id = u.id
    WHERE
        u.user_type = 5 AND u.is_active = 1 AND u.user_imported_flag = 0 AND via_social != '3';

-- user_store_visit
CREATE VIEW user_store_visit AS
    SELECT 
        usv.user_id,
        u.first_name AS user_name,
        u.mobile,
        u.email,
        usv.store_id,
        s.store_name,
        usv.created_at AS visited_at
    FROM
        tbl_user_store_visits AS usv
            LEFT JOIN
        users AS u ON usv.user_id = u.id
            LEFT JOIN
        tbl_stores AS s ON usv.store_id = s.id
	WHERE
        u.user_type = 5 AND u.is_active = 1 AND u.user_imported_flag = 0 AND via_social != '3';

-- store_reward_programe
CREATE VIEW store_reward_programe AS
    SELECT 
        srp.user_id,
        u.first_name AS user_name,
        u.mobile,
        u.email,
        srp.store_id,
        srp.created_at
    FROM
        tbl_store_rewards_programe AS srp
            LEFT JOIN
        users AS u ON srp.user_id = u.id
            LEFT JOIN
        tbl_stores AS s ON srp.store_id = s.id
    WHERE
        u.user_type = 5 AND u.is_active = 1 AND u.user_imported_flag = 0 AND via_social != '3';

-- stores
CREATE VIEW stores AS
    SELECT 
        s.id AS store_id,
        s.store_name,
        s.store_category AS category_id,
        sc.category_name,
        s.is_active,
        sa.city,
        s.store_owner_name,
        s.store_owner_contact_no,
        s.store_owner_email
    FROM
        tbl_stores AS s
            LEFT JOIN
        tbl_store_category AS sc ON s.store_category = sc.id
            LEFT JOIN
        (SELECT DISTINCT
            store_id, city
        FROM
            tbl_store_address) AS sa ON s.id = sa.store_id
    WHERE
        s.is_active = 1;
            
-- store_address
CREATE VIEW store_address AS
    SELECT 
        store_id,
        street_address,
        postal_code,
        city,
        is_active,
        store_lat,
        store_long
    FROM
        tbl_store_address;
        
-- store_category
CREATE VIEW store_category AS
    SELECT 
        id AS category_id, category_name, is_active
    FROM
        tbl_store_category;

-- user_table
CREATE VIEW user_table AS
    SELECT 
        id AS user_id,
        first_name AS user_name,
        mobile,
        email,
        user_type,
        created_at,
        is_active,
        via_social,
        is_admin,
        default_store,
        special_offer,
        plat_form AS platform,
        user_imported_flag,
        latitude,
        longitude,
        location_city,
        intro_video_status,
        added_by,
        review_count,
        review_date,
        update_app_count
    FROM
        users
    WHERE
        is_active = 1;

-- rewads
CREATE VIEW rewards AS
    SELECT 
        id AS reward_id, store_id, pointe, title
    FROM
        tbl_rewards;

-- coupons
CREATE VIEW coupons AS
    SELECT 
        id AS coupon_id, store_id, title
    FROM
        tbl_coupons;
