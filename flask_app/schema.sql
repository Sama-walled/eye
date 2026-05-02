DROP TABLE IF EXISTS prediction;
DROP TABLE IF EXISTS user;
DROP TABLE IF EXISTS AI_Grading;
DROP TABLE IF EXISTS Retinal_Image;
DROP TABLE IF EXISTS AI_Model;
DROP TABLE IF EXISTS Patient;

CREATE TABLE Patient (
    patient_ID INT AUTO_INCREMENT PRIMARY KEY,
    First_Name VARCHAR(100),
    Last_Name VARCHAR(100),
    Email VARCHAR(100),
    Password VARCHAR(255),
    Gender VARCHAR(10),
    Date_of_Birth DATE,
    Contact_Info VARCHAR(255),
    Medical_History TEXT,
    Eye_Center VARCHAR(255),
    Notes TEXT
);

CREATE TABLE Retinal_Image (
    Image_ID INT AUTO_INCREMENT PRIMARY KEY,
    Image_path VARCHAR(255),
    Date_Captured DATETIME,
    patient_ID INT,
    Capture_Device VARCHAR(255),
    FOREIGN KEY (patient_ID) REFERENCES Patient(patient_ID)
);

CREATE TABLE AI_Model (
    Model_ID INT AUTO_INCREMENT PRIMARY KEY,
    Model_Name VARCHAR(255),
    Version VARCHAR(50),
    Developer VARCHAR(255),
    Training_Data_Source TEXT,
    Accuracy DECIMAL(5,2),
    Last_Updated DATE,
    Algorithm TEXT
);

CREATE TABLE AI_Grading (
    AI_Grading_ID INT AUTO_INCREMENT PRIMARY KEY,
    DR_Grade VARCHAR(50),
    Confidence_Score DECIMAL(5,2),
    Grading_Date DATETIME,
    Image_ID INT,
    Model_ID INT,
    FOREIGN KEY (Image_ID) REFERENCES Retinal_Image(Image_ID),
    FOREIGN KEY (Model_ID) REFERENCES AI_Model(Model_ID)
);
