/* Churn Overview */

SELECT COUNT(*) FROM Customers;


SELECT CUSTOMERID, COUNT(*) AS CNT 
FROM CUSTOMERS 
GROUP BY CUSTOMERID 
HAVING COUNT(*) > 1;


/* Q1. How many total customers are there? */
SELECT COUNT(DISTINCT CUSTOMERID) FROM CUSTOMERS;


/* Q2. How many customers churned vs stayed? */
WITH ABC AS (
    SELECT COUNT(*) AS CHURNED_CNT 
    FROM CUSTOMERS 
    WHERE CHURN='Yes'
), 
DEF AS (
    SELECT COUNT(*) AS STAYED_CNT 
    FROM CUSTOMERS 
    WHERE CHURN='No'
)
SELECT ABC.CHURNED_CNT, DEF.STAYED_CNT 
FROM ABC, DEF;


/* Q3. What is the churn rate by gender? */
WITH ABC AS (
    SELECT GENDER, COUNT(*) AS TOTAL 
    FROM CUSTOMERS 
    GROUP BY GENDER
), 
DEF AS (
    SELECT GENDER, COUNT(*) AS CHURN 
    FROM CUSTOMERS 
    WHERE CHURN = 'Yes' 
    GROUP BY GENDER
) 
SELECT ABC.GENDER, 100.0 * DEF.CHURN / ABC.TOTAL AS CHURN_RATE 
FROM ABC 
JOIN DEF ON ABC.GENDER = DEF.GENDER;


/* Q4. Do senior citizens churn more compared to non-senior citizens? */
WITH ABC AS (
    SELECT COUNT(*) AS SENIOR_CHURN 
    FROM SENIOR 
    WHERE CHURN='Yes'
),
DEF AS (
    SELECT COUNT(*) AS NONSENIOR_CHURN 
    FROM BELOW 
    WHERE CHURN='Yes'
)
SELECT CASE 
    WHEN ABC.SENIOR_CHURN > DEF.NONSENIOR_CHURN 
        THEN 'Senior citizen churn more compared to non senior' 
    ELSE 'Non senior churn more compared to senior'
END AS COMPARISON 
FROM ABC, DEF;


/* Q5. What is the churn rate for customers with partners vs without partners? */
WITH ABC AS (
    SELECT PARTNER, COUNT(*) AS TOTAL 
    FROM CUSTOMERS 
    GROUP BY PARTNER
), 
DEF AS (
    SELECT PARTNER, COUNT(*) AS CHURN 
    FROM CUSTOMERS 
    WHERE CHURN = 'Yes' 
    GROUP BY PARTNER
) 
SELECT ABC.PARTNER, 100.0 * DEF.CHURN / ABC.TOTAL AS CHURN_RATE 
FROM ABC 
JOIN DEF ON ABC.PARTNER = DEF.PARTNER;


/* Q6. Do customers with dependents churn less compared to those without? */
WITH ABC AS (
    SELECT COUNT(*) AS DEPENDENT 
    FROM CUSTOMERS 
    WHERE DEPENDENTS = 'Yes' AND CHURN = 'Yes'
), 
DEF AS (
    SELECT COUNT(*) AS NONDEPENDENT 
    FROM CUSTOMERS 
    WHERE DEPENDENTS = 'No' AND CHURN = 'Yes'
) 
SELECT 
    CASE 
        WHEN ABC.DEPENDENT > DEF.NONDEPENDENT THEN 
            'Customers with dependent churn more than customers without dependent'
        ELSE 
            'Customers without dependent churn more than customers with dependent'
    END AS COMPARISON 
FROM ABC, DEF;


/* Q7. Which age group (senior citizen vs non-senior) generates higher average monthly charges? */
SELECT 
    CASE 
        WHEN AVG(S.MONTHLYCHARGES) > AVG(B.MONTHLYCHARGES) THEN 
            'Senior citizen generate more average monthly charges as compared to non senior citizen'
        ELSE 
            'Non senior generate more average monthly charges as compared to senior citizen'
    END AS COMPARISON 
FROM SENIOR S
, BELOW B;


/* Q8. Compare average monthly charges of churned vs non-churned customers. */
WITH ABC AS (
    SELECT AVG(MONTHLYCHARGES) AS CHURNED_AVG 
    FROM CUSTOMERS 
    WHERE CHURN = 'Yes'
), 
DEF AS (
    SELECT AVG(MONTHLYCHARGES) AS NONCHURNED_AVG 
    FROM CUSTOMERS 
    WHERE CHURN = 'No'
) 
SELECT 
    CASE 
        WHEN ABC.CHURNED_AVG > DEF.NONCHURNED_AVG THEN 
            'Average monthly charge of churn is more than average monthly charge of non churn'
        ELSE 
            'Average monthly charge of non churn is more than average monthly charge of churn'
    END AS COMPARISON 
FROM ABC, DEF;


/* Q9. Who are the top 10 customers by total charges? */
WITH ABC AS (
    SELECT 
        CUSTOMERID, 
        DENSE_RANK() OVER (ORDER BY TOTALCHARGES DESC) AS RNK 
    FROM CUSTOMERS
) 
SELECT CUSTOMERID 
FROM ABC 
WHERE RNK <= 10;


/* Q10. Which internet service type (DSL, Fiber optic, None) contributes most to revenue? */
WITH ABC AS (
    SELECT 
        INTERNETSERVICE, 
        SUM(TOTALCHARGES) AS TOTAL, 
        DENSE_RANK() OVER (ORDER BY SUM(TOTALCHARGES) DESC) AS RNK 
    FROM CUSTOMERS 
    GROUP BY INTERNETSERVICE
) 
SELECT INTERNETSERVICE 
FROM ABC 
WHERE RNK = 1;


/* Q11. What is the average tenure of churned customers vs retained customers? */
SELECT 
    CHURN, 
    AVG(TENURE) AS AVG_TENURE 
FROM CUSTOMERS 
GROUP BY CHURN;


/* Q12. Group customers into tenure bands (0–12, 13–24, 25–48, 49+ months) and find churn percentage in each. */
SELECT
    CASE
        WHEN Tenure BETWEEN 0 AND 12 THEN '0-12 months'
        WHEN Tenure BETWEEN 13 AND 24 THEN '13-24 months'
        WHEN Tenure BETWEEN 25 AND 48 THEN '25-48 months'
        ELSE '49+ months'
    END AS Tenure_Band,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned_Customers,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Churn_Percentage
FROM Customers
GROUP BY Tenure_Band
ORDER BY FIELD(Tenure_Band, '0-12 months', '13-24 months', '25-48 months', '49+ months');


/* Q13. Do customers with multiple lines churn more than those with single lines? */
WITH ABC AS (
    SELECT COUNT(*) AS MULTI 
    FROM CUSTOMERS 
    WHERE CHURN = 'Yes' AND MULTIPLELINES = 'Yes'
), 
DEF AS (
    SELECT COUNT(*) AS NONMULTI 
    FROM CUSTOMERS 
    WHERE CHURN = 'Yes' AND MULTIPLELINES = 'No'
) 
SELECT 
    CASE 
        WHEN ABC.MULTI > DEF.NONMULTI THEN 
            'Customers with multiple lines churn more as compared to customers with single lines'
        ELSE 
            'Customers with single Line churn more as compared to customers with multiple Lines'
    END AS COMPARISON 
FROM ABC, DEF;


/* Q14. What is the churn rate for customers with online security vs without? */
WITH ABC AS (
    SELECT ONLINESECURITY, COUNT(*) AS TOTAL 
    FROM CUSTOMERS 
    GROUP BY ONLINESECURITY
), 
DEF AS (
    SELECT ONLINESECURITY, COUNT(*) AS CHURN 
    FROM CUSTOMERS 
    WHERE CHURN = 'Yes' 
    GROUP BY ONLINESECURITY
) 
SELECT ABC.ONLINESECURITY, 100.0 * DEF.CHURN / ABC.TOTAL AS RATE 
FROM ABC 
JOIN DEF ON ABC.ONLINESECURITY = DEF.ONLINESECURITY;


/* Q15. What is the churn rate for customers with tech support vs without? */
WITH ABC AS (
    SELECT TECHSUPPORT, COUNT(*) AS TOTAL 
    FROM CUSTOMERS 
    GROUP BY TECHSUPPORT
), 
DEF AS (
    SELECT TECHSUPPORT, COUNT(*) AS CHURN 
    FROM CUSTOMERS 
    WHERE CHURN = 'Yes' 
    GROUP BY TECHSUPPORT
) 
SELECT ABC.TECHSUPPORT, 100.0 * DEF.CHURN / ABC.TOTAL AS RATE 
FROM ABC 
JOIN DEF ON ABC.TECHSUPPORT = DEF.TECHSUPPORT;


/* Q16. Which payment method has the highest churn rate (electronic check, credit card, bank transfer, mailed check)? */
WITH ABC AS (
    SELECT 
        PAYMENTMETHOD, 
        COUNT(*) AS TOTAL,
        DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS RNK 
    FROM CUSTOMERS 
    GROUP BY PAYMENTMETHOD
) 
SELECT PAYMENTMETHOD 
FROM ABC 
WHERE RNK = 1;


/* Q17. Compare churn rates of customers with and without paperless billing. */
WITH ABC AS (
    SELECT PAPERLESSBILLING, COUNT(*) AS TOTAL 
    FROM CUSTOMERS 
    GROUP BY PAPERLESSBILLING
), 
DEF AS (
    SELECT PAPERLESSBILLING, COUNT(*) AS CHURN 
    FROM CUSTOMERS 
    WHERE CHURN = 'Yes' 
    GROUP BY PAPERLESSBILLING
) 
SELECT ABC.PAPERLESSBILLING, 100.0 * DEF.CHURN / ABC.TOTAL AS RATE 
FROM ABC 
JOIN DEF ON ABC.PAPERLESSBILLING = DEF.PAPERLESSBILLING;


/* Q18. Estimate customer lifetime value (CLV = tenure × monthly charges). Who are the top 5 churned customers by CLV? */
WITH ABC AS (
    SELECT 
        CUSTOMERID, 
        TENURE * MONTHLYCHARGES AS CLV,
        DENSE_RANK() OVER (ORDER BY TENURE * MONTHLYCHARGES DESC) AS RNK 
    FROM CUSTOMERS
) 
SELECT CUSTOMERID AS TOP_5 
FROM ABC 
WHERE RNK <= 5 
ORDER BY RNK ASC;


/* Q19. Compare average CLV of churned vs retained customers. */
WITH ABC AS (
    SELECT AVG(TENURE * MONTHLYCHARGES) AS CHURN 
    FROM CUSTOMERS 
    WHERE CHURN = 'Yes'
), 
DEF AS (
    SELECT AVG(TENURE * MONTHLYCHARGES) AS NONCHURN 
    FROM CUSTOMERS 
    WHERE CHURN = 'No'
) 
SELECT 
    CASE 
        WHEN ABC.CHURN > DEF.NONCHURN THEN 
            'Avg CLV of customers who churned is more than the customers who stayed'
        ELSE 
            'Avg CLV of customers who stayed is more than the customers who churned'
    END AS COMPARISON 
FROM ABC, DEF;


/* Q20. Find the churn rate among high-paying customers (MonthlyCharges > 80). */
WITH ABC AS (
    SELECT COUNT(*) AS HIGHPAYING 
    FROM CUSTOMERS 
    WHERE MONTHLYCHARGES > 80
), 
DEF AS (
    SELECT COUNT(*) AS CHURN 
    FROM CUSTOMERS 
    WHERE MONTHLYCHARGES > 80 AND CHURN = 'Yes'
) 
SELECT 100.0 * DEF.CHURN / ABC.HIGHPAYING AS CHURN_RATE 
FROM ABC, DEF;


/* Q21. Find the churn rate among low-tenure customers (tenure < 12 months). */
WITH ABC AS (
    SELECT COUNT(*) AS LOWTENURE 
    FROM CUSTOMERS 
    WHERE TENURE < 10
), 
DEF AS (
    SELECT COUNT(*) AS CHURN 
    FROM CUSTOMERS 
    WHERE TENURE < 10 AND CHURN = 'Yes'
) 
SELECT 100.0 * DEF.CHURN / ABC.LOWTENURE AS CHURN_RATE 
FROM ABC, DEF;


/* Q22. Which combination of contract type + payment method has the highest churn? */
SELECT CONTRACT, PAYMENTMETHOD, COUNT(*) AS CHURN_COUNT 
FROM CUSTOMERS 
WHERE CHURN = 'Yes' 
GROUP BY CONTRACT, PAYMENTMETHOD 
ORDER BY CHURN_COUNT DESC 
LIMIT 1;