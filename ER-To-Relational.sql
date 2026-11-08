PRAGMA foreign_keys = ON;

CREATE TABLE User (
    UserID TEXT PRIMARY KEY,
    Password INTEGER,
    FullName TEXT,
    PhoneNum TEXT,
    Street TEXT,
    City TEXT,
    State TEXT,
    ZipCode INTEGER,
    RegistrationDate TEXT,
    AccountStatus TEXT
);


CREATE TABLE Rider (
    UserID TEXT PRIMARY KEY,
    RiderSince TEXT,
    FOREIGN KEY (UserID) REFERENCES User(UserID)
);

CREATE TABLE Driver (
    UserID TEXT PRIMARY KEY,
    DLN INTEGER,
    DriverStatus TEXT,
    ApprovalDate TEXT,
	AvgRating Real,
    FOREIGN KEY (UserID) REFERENCES User(UserID)
);

CREATE TABLE SupportStaff (
    UserID TEXT PRIMARY KEY,
    EmployeeID TEXT,
    StaffRole TEXT,
    FOREIGN KEY (UserID) REFERENCES User(UserID)
);

CREATE TABLE Vehicle (
    VehicleID INTEGER PRIMARY KEY,
    DriverID TEXT,
    Make TEXT,
    Model TEXT,
    Year INTEGER,
    LicensePlate TEXT,
    VehicleColor TEXT,
    VehicleCapacity INTEGER,
    FOREIGN KEY (DriverID) REFERENCES Driver(UserID)
);

CREATE TABLE RideTypeCategory (
    CategoryID INTEGER PRIMARY KEY,
    CategoryName TEXT,
    CategoryDesc TEXT,
    ParentCategoryID INTEGER,
    FOREIGN KEY (ParentCategoryID)
        REFERENCES RideTypeCategory(CategoryID)
);

CREATE TABLE RideOffering (
    OfferingID INTEGER PRIMARY KEY,
    DriverID TEXT,
    VehicleID INTEGER,
    CategoryID INTEGER,
    FareRate REAL,
    OfferingDetails TEXT,
    AvailabilityStatus TEXT,
    DateCreated TEXT,
    LastUpdated TEXT,
    FOREIGN KEY (DriverID) REFERENCES Driver(UserID),
    FOREIGN KEY (VehicleID) REFERENCES Vehicle(VehicleID),
    FOREIGN KEY (CategoryID) REFERENCES RideTypeCategory(CategoryID)
);

CREATE TABLE RideRequest (
    RequestID INTEGER PRIMARY KEY,
    RiderID TEXT,
    DriverID TEXT,
    OfferingID INTEGER,
    RequestDateTime TEXT,
    PickupLocation TEXT,
    DropoffLocation TEXT,
    ScheduledPickupTime TEXT,
    ActualPickupTime TEXT,
    CompletionTime TEXT,
    FareAmount REAL,
    RequestStatus TEXT,
    FOREIGN KEY (RiderID) REFERENCES Rider(UserID),
    FOREIGN KEY (DriverID) REFERENCES Driver(UserID),
    FOREIGN KEY (OfferingID) REFERENCES RideOffering(OfferingID)
);

CREATE TABLE PaymentCard (
    CardID INTEGER PRIMARY KEY,
    RiderID TEXT,
    CardType TEXT,
    CardNumber TEXT,
    ExpirationDate TEXT,
    CardholderName TEXT,
    IsDefault INTEGER,
    FOREIGN KEY (RiderID) REFERENCES Rider(UserID)
);

CREATE TABLE Payment (
    PaymentID INTEGER PRIMARY KEY,
    RequestID INTEGER,
    CardID INTEGER,
    PaymentDateTime TEXT,
    Amount REAL,
    PaymentStatus TEXT,
    PaymentMethod TEXT,
    FOREIGN KEY (RequestID) REFERENCES RideRequest(RequestID),
    FOREIGN KEY (CardID) REFERENCES PaymentCard(CardID)
);

CREATE TABLE Review (
    ReviewID INTEGER PRIMARY KEY,
    RiderID TEXT,
    DriverID TEXT,
    RequestID INTEGER,
    Rating INTEGER,
    ReviewComment TEXT,
    ReviewDate TEXT,
    FOREIGN KEY (RiderID) REFERENCES Rider(UserID),
    FOREIGN KEY (DriverID) REFERENCES Driver(UserID),
    FOREIGN KEY (RequestID) REFERENCES RideRequest(RequestID)
);

CREATE TABLE DriverApplication (
    ApplicationID INTEGER PRIMARY KEY,
    ApplicantID TEXT,
    ReviewedBy TEXT,
    ApplicationDate TEXT,
    ApplicationStatus TEXT,
    DecisionDate TEXT,
    DecisionNotes TEXT,
    FOREIGN KEY (ApplicantID) REFERENCES Rider(UserID),
    FOREIGN KEY (ReviewedBy) REFERENCES SupportStaff(UserID)
);

CREATE TABLE CategoryApplication (
    CategoryApplicationID INTEGER PRIMARY KEY,
    DriverID TEXT,
    ReviewedBy TEXT,
    ProposedCategoryName TEXT,
    ProposedDescription TEXT,
    ApplicationDate TEXT,
    ApplicationStatus TEXT,
    DecisionDate TEXT,
    DecisionNotes TEXT,
    FOREIGN KEY (DriverID) REFERENCES Driver(UserID),
    FOREIGN KEY (ReviewedBy) REFERENCES SupportStaff(UserID)
);

CREATE TABLE Question (
    QuestionID INTEGER PRIMARY KEY,
    RiderID TEXT,
    OfferingID INTEGER,
    QuestionText TEXT,
    QuestionDateTime TEXT,
    AnswerText TEXT,
    AnswerDateTime TEXT,
    QuestionStatus TEXT,
    FOREIGN KEY (RiderID) REFERENCES Rider(UserID),
    FOREIGN KEY (OfferingID) REFERENCES RideOffering(OfferingID)
);

CREATE TABLE SupportRequest (
    SupportRequestID INTEGER PRIMARY KEY,
    UserID TEXT,
    AssignedStaffID TEXT,
    RequestType TEXT,
    RequestDesc TEXT,
    SubmissionDate TEXT,
    RequestStatus TEXT,
    Notes TEXT,
    FOREIGN KEY (UserID) REFERENCES User(UserID),
    FOREIGN KEY (AssignedStaffID) REFERENCES SupportStaff(UserID)
);

CREATE TABLE CancellationRequest (
    CancellationID INTEGER PRIMARY KEY,
    RequestID INTEGER,
    SubmittedByUserID TEXT,
    ReviewedBy TEXT,
    SubmissionDate TEXT,
    CancellationReason TEXT,
    MutualAgreementStatus TEXT,
    ApprovalStatus TEXT,
    FOREIGN KEY (RequestID) REFERENCES RideRequest(RequestID),
    FOREIGN KEY (SubmittedByUserID) REFERENCES User(UserID),
    FOREIGN KEY (ReviewedBy) REFERENCES SupportStaff(UserID)
);

CREATE TABLE Refund (
    RefundID INTEGER PRIMARY KEY,
    PaymentID INTEGER,
    CancellationID INTEGER,
    RefundAmount REAL,
    RefundStatus TEXT,
    RefundDateTime TEXT,
    FOREIGN KEY (PaymentID) REFERENCES Payment(PaymentID),
    FOREIGN KEY (CancellationID)
        REFERENCES CancellationRequest(CancellationID)
);

CREATE TABLE SafetyAlert (
    AlertID INTEGER PRIMARY KEY,
    RequestID INTEGER,
    ReportedByUserID TEXT,
    AlertType TEXT,
    AlertDescription TEXT,
    AlertDateTime TEXT,
    Latitude REAL,
    Longitude REAL,
    SeverityLevel TEXT,
    AlertStatus TEXT,
    FOREIGN KEY (RequestID) REFERENCES RideRequest(RequestID),
    FOREIGN KEY (ReportedByUserID) REFERENCES User(UserID)
);

CREATE TABLE SafetyAlertResponse (
    ResponseID INTEGER PRIMARY KEY,
    AlertID INTEGER,
    SupportStaffID TEXT,
    ResponseDescription TEXT,
    ResponseDateTime TEXT,
    FOREIGN KEY (AlertID) REFERENCES SafetyAlert(AlertID),
    FOREIGN KEY (SupportStaffID) REFERENCES SupportStaff(UserID)
);