-- Step 1: Create the database and select it
CREATE DATABASE LittleLemon_Database2222;
USE LittleLemon_Database2222;

-- Step 2: Create the Customers table
CREATE TABLE Customers (
    CustomerID VARCHAR(20) PRIMARY KEY,
    CustomerName VARCHAR(100),
    City VARCHAR(100),
    Country VARCHAR(100),
    PostalCode VARCHAR(20),
    CountryCode VARCHAR(10)
);

-- Step 3: Create the Bookings table
CREATE TABLE Bookings (
    BookingID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID VARCHAR(20),
    OrderDate DATE,
    DeliveryDate DATE,
    Quantity INT,
    Status ENUM('Active', 'Canceled') DEFAULT 'Active',
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Step 4: Create the Orders table
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

-- Step 5: Create GetMaxQuantity Procedure
DELIMITER //

CREATE PROCEDURE GetMaxQuantity(OUT maxQuantity INT)
BEGIN
    SELECT IFNULL(MAX(Quantity), 0) INTO maxQuantity FROM Bookings;
END //

DELIMITER ;

-- Step 6: Create ManageBooking Procedure
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

-- Step 7: Create UpdateBooking Procedure
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

-- Step 8: Create AddBooking Procedure
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

-- Step 9: Create CancelBooking Procedure
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

-- Step 10: Create Trigger to Automatically Update Booking Status
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

-- Step 11: Create Trigger to automatically update Sales 
DELIMITER //

CREATE TRIGGER UpdateSalesBeforeInsert
BEFORE INSERT ON Orders
FOR EACH ROW
BEGIN
    SET NEW.Sales = (NEW.Quantity * NEW.Cost) * (1 - NEW.Discount / 100);
END //

DELIMITER ;
