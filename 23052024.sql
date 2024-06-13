-- Declare a variable to hold the status
DO $$ 
DECLARE
    v_status VARCHAR;
BEGIN
    -- Insert a new customer
    v_status := '';
    CALL dbo.UspInsertCustomerdetails(
        par_firstname := 'John',
        par_lastname := 'Doe',
        par_email := 'john.doe@example.com',
        par_phone := '123-456-7890',
        par_organisation := 'Example Corp',
        par_role := 'Manager',
        par_status := v_status
    );
    RAISE NOTICE 'Status: %', v_status;
    
    -- Insert another new customer
    v_status := '';
    CALL dbo.UspInsertCustomerdetails(
        par_firstname := 'Jane',
        par_lastname := 'Smith',
        par_email := 'jane.smith@example.com',
        par_phone := '987-654-3210',
        par_organisation := 'Another Corp',
        par_role := 'Developer',
        par_status := v_status
    );
    RAISE NOTICE 'Status: %', v_status;

    -- Update an existing customer
    v_status := '';
    CALL dbo.UspInsertCustomerdetails(
        par_firstname := 'Johnny',
        par_lastname := 'Doe',
        par_email := 'john.doe@example.com',
        par_phone := '123-456-7890',
        par_organisation := 'Example Corp',
        par_role := 'Senior Manager',
        par_status := v_status
    );
    RAISE NOTICE 'Status: %', v_status;
END $$;

select * from dbo.tblcustomers

-----------------
DO $$ 
DECLARE
    v_status VARCHAR;
BEGIN
    -- Insert a new customer
    v_status := '';
    CALL dbo.UspInsertCustomerdetails(
        par_firstname := 'John',
        par_lastname := 'Doe',
        par_email := 'john.doe@example.com',
        par_phone := '123-456-7890',
        par_organisation := 'Example Corp',
        par_role := 'Manager',
        par_status := v_status
    );
    RAISE NOTICE 'Status: %', v_status;
----------------
DO $$
DECLARE 
	v_status VARCHAR;
BEGIN 
	v_status := '';
	CALL dbo.UspInsertCustomerdetails(
	par_firstname := 'Ram',
	par_lastname := 'Pavan',
	par_email := 'raghu@12',
	par_phone := '',
	par_organisation := '',
	par_role := '',
	par_status := vstatus
	);
	Raise Notice 'status:%',v_status;
END $$;
---------------------------------------------------------------
DO $$ 
DECLARE
    v_status VARCHAR;
BEGIN
    -- Insert a new customer
    v_status := '';
    CALL dbo.UspInsertCustomerdetails(
        par_firstname := 'John',
        par_lastname := 'Doe',
        par_email := 'john.doe@example.com',
        par_phone := '123-456-7890',
        par_organisation := 'Example Corp',
        par_role := 'Manager',
        par_status := v_status
    );
    RAISE NOTICE 'Status: %', v_status;
END $$;

DO $$
DECLARE 
    v_status VARCHAR;
BEGIN 
    v_status := '';
    CALL dbo.UspInsertCustomerdetails(
        par_firstname := 'Ram',
        par_lastname := 'Pavan',
        par_email := 'raghu@12',
        par_phone := '',
        par_organisation := '',
        par_role := '',
        par_status := v_status
    );
    RAISE NOTICE 'Status: %', v_status;
END $$;

select * from dbo.tblcustomers order by 1  

DO $$
DECLARE 
    v_status VARCHAR;
BEGIN 
    v_status := '';
    CALL dbo.UspInsertCustomerdetails(
        par_firstname := 'Antony',
        par_lastname := 'Seb',
        par_email := 'raghu@12',
        par_phone := '',
        par_organisation := '',
        par_role := '',
        par_status := v_status
    );
    RAISE NOTICE 'Status: %', v_status;
END $$;


DO $$
DECLARE 
    v_status VARCHAR;
BEGIN 
    v_status := '';
    CALL dbo.UspInsertCustomerdetails(
        par_firstname := 'Ranganna',
        par_lastname := 'Ranga',
        par_email := 'ranganna.rana@hotmail.co.in',
        par_phone := '',
        par_organisation := 'ACZ',
        par_role := '',
        par_status := v_status
    );
    RAISE NOTICE 'Status: %', v_status;
END $$;

select * from dbo.tblcustomers


