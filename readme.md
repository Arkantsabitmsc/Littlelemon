# Little Lemon Database README

## Overview

The Little Lemon Database is designed to manage customer bookings, orders, and related data for a restaurant. This document provides an overview of the database schema, including tables, stored procedures, and triggers that facilitate the management of customer information and bookings.

### Explanation of the SQL Code

## Step 1: Create the Database and Select It
CREATE DATABASE LittleLemon_Database2222;
USE LittleLemon_Database2222;

# explanation 
CREATE DATABASE: This command creates a new database named LittleLemon_Database2222. This database will serve as the storage for all related tables and data for the Little Lemon application.
USE: This command selects the newly created database for subsequent operations. All following SQL commands will be executed within this database context.

# Step 2: Create the Customers Table
CREATE TABLE Customers (
    CustomerID VARCHAR(20) PRIMARY KEY,
    CustomerName VARCHAR(100),
    City VARCHAR(100),
    Country VARCHAR(100),
    PostalCode VARCHAR(20),
    CountryCode VARCHAR(10)
);

# explanation 
CREATE TABLE Customers: This command creates a new table named Customers to store customer information.
Columns:
CustomerID: A unique identifier for each customer, defined as a VARCHAR(20) and set as the PRIMARY KEY. This ensures that each customer has a unique ID.
CustomerName: A VARCHAR(100) field to store the name of the customer.
City: A VARCHAR(100) field to store the city where the customer resides.
Country: A VARCHAR(100) field to store the country of the customer.
PostalCode: A VARCHAR(20) field to store the postal code of the customer's address.
CountryCode: A VARCHAR(10) field to store the country code, which can be useful for international operations.

# Step 3: Create the Bookings Table
CREATE TABLE Bookings (
    BookingID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID VARCHAR(20),
    OrderDate DATE,
    DeliveryDate DATE,
    Quantity INT,
    Status ENUM('Active', 'Canceled') DEFAULT 'Active',
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

# explanation 
CREATE TABLE Bookings: This command creates a new table named Bookings to manage customer bookings.
Columns:
BookingID: An integer that automatically increments with each new booking, serving as the primary key for the table. This ensures each booking has a unique identifier.
CustomerID: A VARCHAR(20) field that links each booking to a specific customer. This is a foreign key referencing the CustomerID in the Customers table, establishing a relationship between the two tables.
OrderDate: A DATE field to store the date when the booking was made.
DeliveryDate: A DATE field to store the expected delivery date for the booking.
Quantity: An integer field to indicate the number of items booked.
Status: An ENUM field that can take values 'Active' or 'Canceled', with a default value of 'Active'. This field tracks the current status of the booking.
FOREIGN KEY: This constraint ensures referential integrity by linking CustomerID in the Bookings table to CustomerID in the Customers table. It ensures that a booking cannot exist without a corresponding customer.
Summary
The SQL code provided establishes a foundational structure for a database that manages customer information and their bookings. The Customers table stores essential details about each customer, while the Bookings table tracks the bookings made by these customers, including their status and relevant dates. The use of primary and foreign keys ensures data integrity and establishes relationships between the tables, which is crucial for maintaining a well-organized database system.


## Step 4: Create the Orders Table
CREATE TABLE Orders (
    OrderID VARCHAR(20) PRIMARY KEY,
    OrderDate DATE,
    DeliveryDate DATE,
    CustomerID VARCHAR(20),
    Cost DECIMAL(10, 2),
    Sales DECIMAL(10, 2),
    Quantity INT,
    Discount DECIMAL(5, 2),
    DeliveryCost DECIMAL(10, 2),
    CourseName VARCHAR(100),
    CuisineName VARCHAR(100),
    StarterName VARCHAR(100),
    DessertName VARCHAR(100),
    Drink VARCHAR(100),
    Sides VARCHAR(100),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

# explanation 
CREATE TABLE Orders: This command creates a table named Orders to store order details.
Columns:
OrderID: A unique identifier for each order, defined as a VARCHAR(20) and set as the primary key.
OrderDate: The date when the order was placed, defined as a DATE.
DeliveryDate: The date when the order is scheduled for delivery, defined as a DATE.
CustomerID: A foreign key that references the CustomerID in the Customers table, linking each order to a specific customer.
Cost: The total cost of the order, defined as a DECIMAL(10, 2).
Sales: The calculated sales amount for the order, defined as a DECIMAL(10, 2).
Quantity: The number of items ordered, defined as an INT.
Discount: The discount applied to the order, defined as a DECIMAL(5, 2).
DeliveryCost: The cost associated with delivering the order, defined as a DECIMAL(10, 2).
CourseName, CuisineName, StarterName, DessertName, Drink, Sides: Various fields to store details about the order items.

## Step 5: Create GetMaxQuantity Procedure
DELIMITER //

CREATE PROCEDURE GetMaxQuantity(OUT maxQuantity INT)
BEGIN
    SELECT IFNULL(MAX(Quantity), 0) INTO maxQuantity FROM Bookings;
END //

DELIMITER ;

# explanation 
CREATE PROCEDURE GetMaxQuantity: This stored procedure retrieves the maximum quantity from the Bookings table.
OUT maxQuantity: This parameter will hold the output value of the maximum quantity.
IFNULL(MAX(Quantity), 0): This SQL function returns the maximum quantity, or 0 if there are no bookings, ensuring that the output is always a valid integer.

## Step 6: Create ManageBooking Procedure
DELIMITER //

CREATE PROCEDURE ManageBooking(IN bookingID INT, IN action VARCHAR(10), IN newQuantity INT)
BEGIN
    DECLARE bookingExists INT;

    -- Check if the booking exists
    SELECT COUNT(*) INTO bookingExists FROM Bookings WHERE BookingID = bookingID;

    IF action = 'view' THEN
        IF bookingExists > 0 THEN
            SELECT * FROM Bookings WHERE BookingID = bookingID;
        ELSE
            SELECT 'Booking not found' AS Message;
        END IF;
    ELSEIF action = 'delete' THEN
        IF bookingExists > 0 THEN
            DELETE FROM Bookings WHERE BookingID = bookingID;
            SELECT 'Booking deleted successfully' AS Message;
        ELSE
            SELECT 'Booking not found' AS Message;
        END IF;
    ELSEIF action = 'modify' THEN
        IF bookingExists > 0 THEN
            UPDATE Bookings SET Quantity = newQuantity WHERE BookingID = bookingID;
            SELECT 'Booking updated successfully' AS Message;
        ELSE
            SELECT 'Booking not found' AS Message;
        END IF;
    ELSE
        SELECT 'Invalid action' AS Message;
    END IF;
END //

DELIMITER ;

# explanation 
CREATE PROCEDURE ManageBooking: This stored procedure manages bookings based on the specified action (view, delete, or modify).
IN bookingID: The ID of the booking to manage.
IN action: The action to perform (view, delete, or modify).
IN newQuantity: The new quantity to set if modifying the booking.
Logic: The procedure checks if the booking exists and performs the specified action, returning appropriate messages for each case.

## Step 7: Create UpdateBooking Procedure
DELIMITER //

CREATE PROCEDURE UpdateBooking(IN bookingID INT, IN newQuantity INT, IN newDeliveryDate DATE)
BEGIN
    DECLARE bookingExists INT;

    SELECT COUNT(*) INTO bookingExists FROM Bookings WHERE BookingID = bookingID;

    IF bookingExists > 0 THEN
        IF newDeliveryDate < (SELECT OrderDate FROM Bookings WHERE BookingID = bookingID) THEN
            SELECT 'Delivery date cannot be before order date' AS Message;
        ELSE
            UPDATE Bookings SET Quantity = newQuantity, DeliveryDate = newDeliveryDate WHERE BookingID = bookingID;
            SELECT 'Booking updated successfully' AS Message;
        END IF;
    ELSE
        SELECT 'Booking not found' AS Message;
    END IF;
END //

DELIMITER ;

# explanation
CREATE PROCEDURE UpdateBooking: This stored procedure updates the quantity and delivery date of a booking.
IN bookingID: The ID of the booking to update.
IN newQuantity: The new quantity to set.
IN newDeliveryDate: The new delivery date to set.
Logic: The procedure checks if the booking exists and ensures that the new delivery date is not before the order date. If valid, it updates the booking and returns a success message.

## Step 8: Create AddBooking Procedure
DELIMITER //

CREATE PROCEDURE AddBooking(IN customerID VARCHAR(20), IN bookingDate DATE, IN deliveryDate DATE, IN quantity INT)
BEGIN
    DECLARE customerExists INT;

    SELECT COUNT(*) INTO customerExists FROM Customers WHERE CustomerID = customerID;

    IF customerExists > 0 THEN
        IF deliveryDate < bookingDate THEN
            SELECT 'Delivery date cannot be before order date' AS Message;
        ELSE
            INSERT INTO Bookings (CustomerID, OrderDate, DeliveryDate, Quantity) VALUES (customerID, bookingDate, deliveryDate, quantity);
            SELECT 'Booking added successfully' AS Message;
        END IF;
    ELSE
        SELECT 'Customer not found' AS Message;
    END IF;
END //

DELIMITER ;

# explanation
CREATE PROCEDURE AddBooking: This stored procedure adds a new booking for a customer.
IN customerID: The ID of the customer making the booking.
IN bookingDate: The date of the booking.
IN deliveryDate: The date of delivery.
IN quantity: The quantity of items booked.
Logic: The procedure checks if the customer exists and ensures that the delivery date is not before the booking date. If valid, it inserts the new booking and returns a success message.

## Step 9: Create CancelBooking Procedure
DELIMITER //

CREATE PROCEDURE CancelBooking(IN bookingID INT)
BEGIN
    DECLARE bookingExists INT;

    SELECT COUNT(*) INTO bookingExists FROM Bookings WHERE BookingID = bookingID;

    IF bookingExists > 0 THEN
        UPDATE Bookings SET Status = 'Canceled' WHERE BookingID = bookingID;
        SELECT 'Booking canceled successfully' AS Message;
    ELSE
        SELECT 'Booking not found' AS Message;
    END IF;
END //

DELIMITER ;

# explanation
CREATE PROCEDURE CancelBooking: This stored procedure cancels a booking.
IN bookingID: The ID of the booking to cancel.
Logic: The procedure checks if the booking exists and updates its status to 'Canceled'. It returns a success message or an error message if the booking is not found.

## Step 10: Create Trigger to Automatically Update Booking Status
DELIMITER //

CREATE TRIGGER UpdateBookingStatus
BEFORE UPDATE ON Bookings
FOR EACH ROW
BEGIN
    IF NEW.DeliveryDate < NEW.OrderDate THEN
        SET NEW.Status = 'Canceled';
    END IF;
END //

DELIMITER ;

# explanation
CREATE TRIGGER UpdateBookingStatus: This trigger automatically updates the status of a booking before it is updated.
Logic: If the new delivery date is before the order date, the trigger sets the status of the booking to 'Canceled', ensuring that invalid bookings are not allowed.

## Step 11: Create Trigger to Automatically Update Sales
DELIMITER //

CREATE TRIGGER UpdateSalesBeforeInsert
BEFORE INSERT ON Orders
FOR EACH ROW
BEGIN
    SET NEW.Sales = (NEW.Quantity * NEW.Cost) * (1 - NEW.Discount / 100);
END //

DELIMITER ;

# explanation
CREATE TRIGGER UpdateSalesBeforeInsert: This trigger automatically calculates the sales amount before a new order is inserted.
Logic: It sets the Sales field based on the quantity, cost, and discount, ensuring that the sales amount is calculated correctly at the time of insertion.

## Summary
This SQL code establishes a comprehensive database structure for managing customers, bookings, and orders. It includes the creation of tables with appropriate relationships, as well as stored procedures for managing bookings and triggers for maintaining data integrity and automating calculations. Each component is designed to ensure that the database operates efficiently and accurately, providing a solid foundation for an application that handles customer bookings and orders.