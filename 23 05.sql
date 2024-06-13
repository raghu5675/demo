-- DROP TABLE IF EXISTS dbo.tblcustomers;

CREATE TABLE IF NOT EXISTS dbo.tblcustomers
(
    customerid BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 ),
    firstname character varying(200),
    lastname character varying(200),
    email character varying(200) NOT NULL,
    phone character varying(20),
    organisation character varying(200),
    role character varying(100),
    createddate timestamp NULL DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(6)),
	isdeleted numeric DEFAULT 0
);

--DROP PROCEDURE IF EXISTS dbo.UspInsertCustomerdetails(character varying, character varying, character varying, character varying, character varying, character varying, character varying);

CREATE OR REPLACE PROCEDURE dbo.UspInsertCustomerdetails(
    par_firstname character varying,
    par_lastname character varying,
    par_email character varying,
    par_phone character varying,
    par_organisation character varying,
    par_role character varying,
    INOUT par_status character varying
)
LANGUAGE plpgsql
AS $$
	BEGIN
    
        IF NOT EXISTS (SELECT 1 FROM dbo.tblcustomers WHERE email = par_email AND isdeleted = 0) THEN
		
            INSERT INTO dbo.tblcustomers (
                firstname, lastname, email, phone, organisation, role
            ) VALUES (
                par_firstname, par_lastname, par_email, par_phone, par_organisation, par_role
            );
            par_status := 'S001'; 
        ELSE
           
            UPDATE dbo.tblcustomers
            SET
                firstname = par_firstname,
                lastname = par_lastname,
                phone = par_phone,
                organisation = par_organisation,
                role = par_role
				
            WHERE email = par_email AND isdeleted = 0;
			
            par_status := 'S002'; 
        END IF;
		
        EXCEPTION WHEN OTHERS THEN
		
		RAISE EXCEPTION 'An error occurred: %', SQLERRM;
		
		par_status := 'F001'; 
   
	END;
$$;

