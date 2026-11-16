BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS CancellationRequest (
    CancellationID INTEGER PRIMARY KEY NOT NULL,
    RequestID INTEGER NOT NULL,
    SubmittedByUserID TEXT NOT NULL,
    ReviewedBy TEXT,
    SubmissionDate TEXT NOT NULL,
    CancellationReason TEXT NOT NULL,
    MutualAgreementStatus TEXT NOT NULL
        CHECK (MutualAgreementStatus IN (
            'pending', 'agreed', 'declined', 'not_required'
        )),
    ApprovalStatus TEXT NOT NULL
        CHECK (ApprovalStatus IN ('pending', 'approved', 'rejected')),

    CHECK (
        ApprovalStatus != 'approved'
        OR MutualAgreementStatus IN ('agreed', 'not_required')
    ),

    CHECK (
        (ApprovalStatus = 'pending' AND ReviewedBy IS NULL)
        OR
        (ApprovalStatus IN ('approved', 'rejected')
            AND ReviewedBy IS NOT NULL)
    ),

    FOREIGN KEY (RequestID) REFERENCES RideRequest(RequestID),
    FOREIGN KEY (SubmittedByUserID) REFERENCES User(UserID),
    FOREIGN KEY (ReviewedBy) REFERENCES SupportStaff(UserID)
);
CREATE TABLE IF NOT EXISTS CategoryApplication (
    CategoryApplicationID INTEGER PRIMARY KEY NOT NULL,
    DriverID TEXT NOT NULL,
    ReviewedBy TEXT,
    ProposedCategoryName TEXT NOT NULL,
    ProposedDescription TEXT,
    ApplicationDate TEXT NOT NULL,
    ApplicationStatus TEXT NOT NULL
        CHECK (ApplicationStatus IN ('pending', 'approved', 'rejected')),
    DecisionDate TEXT,
    DecisionNotes TEXT,

    CHECK (
        (ApplicationStatus = 'pending'
            AND DecisionDate IS NULL
            AND ReviewedBy IS NULL)
        OR
        (ApplicationStatus IN ('approved', 'rejected')
            AND DecisionDate IS NOT NULL
            AND ReviewedBy IS NOT NULL)
    ),

    FOREIGN KEY (DriverID) REFERENCES Driver(UserID),
    FOREIGN KEY (ReviewedBy) REFERENCES SupportStaff(UserID)
);
CREATE TABLE IF NOT EXISTS "Driver" (
	"UserID"	TEXT NOT NULL,
	"DLN"	TEXT NOT NULL UNIQUE,
	"DriverStatus"	TEXT NOT NULL CHECK("DriverStatus" IN ('active', 'suspended', 'inactive')),
	"ApprovalDate"	TEXT NOT NULL,
	PRIMARY KEY("UserID"),
	FOREIGN KEY("UserID") REFERENCES "User"("UserID")
);
CREATE TABLE IF NOT EXISTS DriverApplication (
    ApplicationID INTEGER PRIMARY KEY NOT NULL,
    ApplicantID TEXT NOT NULL,
    ReviewedBy TEXT,
    ApplicationDate TEXT NOT NULL,
    ApplicationStatus TEXT NOT NULL
        CHECK (ApplicationStatus IN ('pending', 'approved', 'rejected')),
    DecisionDate TEXT,
    DecisionNotes TEXT,
    CHECK (
        (ApplicationStatus = 'pending'
            AND DecisionDate IS NULL
            AND ReviewedBy IS NULL)
        OR
        (ApplicationStatus IN ('approved', 'rejected')
            AND DecisionDate IS NOT NULL
            AND ReviewedBy IS NOT NULL)
    ),

    FOREIGN KEY (ApplicantID) REFERENCES Rider(UserID),
    FOREIGN KEY (ReviewedBy) REFERENCES SupportStaff(UserID)
);
CREATE TABLE IF NOT EXISTS "Payment" (
	"PaymentID"	INTEGER NOT NULL,
	"RequestID"	INTEGER NOT NULL,
	"CardID"	INTEGER,
	"PaymentDateTime"	TEXT NOT NULL,
	"Amount"	REAL NOT NULL CHECK("Amount" > 0),
	"PaymentStatus"	TEXT NOT NULL CHECK("PaymentStatus" IN ('pending', 'successful', 'failed')),
	"PaymentMethod"	TEXT NOT NULL,
	"TransactionType"	TEXT NOT NULL,
	PRIMARY KEY("PaymentID"),
	FOREIGN KEY("CardID") REFERENCES "PaymentCard"("CardID"),
	FOREIGN KEY("RequestID") REFERENCES "RideRequest"("RequestID")
);
CREATE TABLE IF NOT EXISTS PaymentCard (
    CardID INTEGER PRIMARY KEY NOT NULL,
    RiderID TEXT NOT NULL,
    CardType TEXT NOT NULL,
    CardToken TEXT NOT NULL UNIQUE,
    LastFour TEXT NOT NULL
        CHECK (length(LastFour) = 4),
    ExpirationDate TEXT NOT NULL,
    CardholderName TEXT NOT NULL,
    IsDefault INTEGER NOT NULL
        CHECK (IsDefault IN (0, 1)),

    FOREIGN KEY (RiderID) REFERENCES Rider(UserID)
);
CREATE TABLE IF NOT EXISTS Question (
    QuestionID INTEGER PRIMARY KEY NOT NULL,
    RiderID TEXT NOT NULL,
    OfferingID INTEGER NOT NULL,
    QuestionText TEXT NOT NULL,
    QuestionDateTime TEXT NOT NULL,
    AnswerText TEXT,
    AnswerDateTime TEXT,
    QuestionStatus TEXT NOT NULL
        CHECK (QuestionStatus IN ('pending', 'answered')),

    CHECK (
        (QuestionStatus = 'pending'
            AND AnswerText IS NULL
            AND AnswerDateTime IS NULL)
        OR
        (QuestionStatus = 'answered'
            AND AnswerText IS NOT NULL
            AND AnswerDateTime IS NOT NULL)
    ),

    FOREIGN KEY (RiderID) REFERENCES Rider(UserID),
    FOREIGN KEY (OfferingID) REFERENCES RideOffering(OfferingID)
);
CREATE TABLE IF NOT EXISTS Refund (
    RefundID INTEGER PRIMARY KEY NOT NULL,
    PaymentID INTEGER NOT NULL,
    CancellationID INTEGER NOT NULL,
    RefundAmount REAL NOT NULL CHECK (RefundAmount > 0),
    RefundStatus TEXT NOT NULL
        CHECK (RefundStatus IN ('pending', 'successful', 'failed')),
    RefundDateTime TEXT,
    CHECK (
        (RefundStatus = 'successful' AND RefundDateTime IS NOT NULL)
        OR
        (RefundStatus != 'successful' AND RefundDateTime IS NULL)
    ),

    FOREIGN KEY (PaymentID) REFERENCES Payment(PaymentID),
    FOREIGN KEY (CancellationID)
        REFERENCES CancellationRequest(CancellationID)
);
CREATE TABLE IF NOT EXISTS RegistrationApproval (
    RegistrationID INTEGER PRIMARY KEY NOT NULL,
    UserID TEXT NOT NULL UNIQUE,
    ReviewedBy TEXT,
    RegistrationDate TEXT NOT NULL,

    ApprovalStatus TEXT NOT NULL
        CHECK (ApprovalStatus IN ('pending', 'approved', 'rejected')),

    DecisionDate TEXT,
    DecisionNotes TEXT,

    CHECK (
        (ApprovalStatus = 'pending'
            AND DecisionDate IS NULL
            AND ReviewedBy IS NULL)
        OR
        (ApprovalStatus IN ('approved', 'rejected')
            AND DecisionDate IS NOT NULL
            AND ReviewedBy IS NOT NULL)
    ),

    FOREIGN KEY (UserID) REFERENCES User(UserID),
    FOREIGN KEY (ReviewedBy) REFERENCES SupportStaff(UserID)
);
CREATE TABLE IF NOT EXISTS Review (
    ReviewID INTEGER PRIMARY KEY NOT NULL,
    RequestID INTEGER NOT NULL UNIQUE,
    Rating INTEGER NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    ReviewComment TEXT,
    ReviewDate TEXT NOT NULL,

    FOREIGN KEY (RequestID) REFERENCES RideRequest(RequestID)
);
CREATE TABLE IF NOT EXISTS "RideOffering" (
	"OfferingID"	INTEGER NOT NULL,
	"VehicleID"	INTEGER NOT NULL,
	"CategoryID"	INTEGER NOT NULL,
	"FareRate"	REAL NOT NULL CHECK("FareRate" > 0),
	"OfferingDetails"	TEXT,
	"AvailabilityStatus"	TEXT NOT NULL CHECK("AvailabilityStatus" IN ('available', 'unavailable', 'fully_booked')),
	"DateCreated"	TEXT NOT NULL,
	"LastUpdated"	TEXT NOT NULL,
	PRIMARY KEY("OfferingID"),
	FOREIGN KEY("CategoryID") REFERENCES "RideTypeCategory"("CategoryID"),
	FOREIGN KEY("VehicleID") REFERENCES "Vehicle"("VehicleID")
);
CREATE TABLE IF NOT EXISTS "RideRequest" (
	"RequestID"	INTEGER NOT NULL,
	"RiderID"	TEXT NOT NULL,
	"OfferingID"	INTEGER NOT NULL,
	"RequestDateTime"	TEXT NOT NULL,
	"PickupLocation"	TEXT NOT NULL,
	"DropoffLocation"	TEXT NOT NULL,
	"PickupZipCode"	TEXT NOT NULL,
	"DropoffZipCode"	TEXT NOT NULL,
	"ScheduledPickupTime"	TEXT,
	"ActualPickupTime"	TEXT,
	"CompletionTime"	TEXT,
	"FareAmount"	REAL NOT NULL CHECK("FareAmount" > 0),
	"RequestStatus"	TEXT NOT NULL CHECK("RequestStatus" IN ('pending', 'accepted', 'in_progress', 'completed', 'canceled')),
	"SeatCount"	INTEGER NOT NULL CHECK("SeatCount">0),
	PRIMARY KEY("RequestID"),
	FOREIGN KEY("DropoffZipCode") REFERENCES "ZipCode"("ZipCode"),
	FOREIGN KEY("OfferingID") REFERENCES "RideOffering"("OfferingID"),
	FOREIGN KEY("PickupZipCode") REFERENCES "ZipCode"("ZipCode"),
	FOREIGN KEY("RiderID") REFERENCES "Rider"("UserID"),
	CHECK(("RequestStatus" = 'completed' AND "CompletionTime" IS NOT NULL) OR ("RequestStatus" != 'completed' AND "CompletionTime" IS NULL))
);
CREATE TABLE IF NOT EXISTS RideTypeCategory (
    CategoryID INTEGER PRIMARY KEY NOT NULL,
    CategoryName TEXT NOT NULL UNIQUE,
    CategoryDesc TEXT,
    ParentCategoryID INTEGER,
    CHECK (
        ParentCategoryID IS NULL
        OR ParentCategoryID != CategoryID
    ),

    FOREIGN KEY (ParentCategoryID)
        REFERENCES RideTypeCategory(CategoryID)
);
CREATE TABLE IF NOT EXISTS Rider (
    UserID TEXT PRIMARY KEY NOT NULL,
    RiderSince TEXT NOT NULL,
    FOREIGN KEY (UserID) REFERENCES User(UserID)
);
CREATE TABLE IF NOT EXISTS SafetyAlert (
    AlertID INTEGER PRIMARY KEY NOT NULL,
    RequestID INTEGER NOT NULL,
    ReportedByUserID TEXT NOT NULL,
    AlertType TEXT NOT NULL
        CHECK (AlertType IN (
            'emergency', 'accident', 'harassment',
            'suspicious_activity', 'other'
        )),
    AlertDescription TEXT NOT NULL,
    AlertDateTime TEXT NOT NULL,
    Latitude REAL,
    Longitude REAL,
    SeverityLevel TEXT NOT NULL
        CHECK (SeverityLevel IN ('low', 'medium', 'high', 'critical')),
    AlertStatus TEXT NOT NULL
        CHECK (AlertStatus IN (
            'open', 'investigating', 'resolved', 'closed'
        )),

    CHECK (
        (Latitude IS NULL AND Longitude IS NULL)
        OR
        (Latitude BETWEEN -90 AND 90
            AND Longitude BETWEEN -180 AND 180)
    ),

    FOREIGN KEY (RequestID) REFERENCES RideRequest(RequestID),
    FOREIGN KEY (ReportedByUserID) REFERENCES User(UserID)
);
CREATE TABLE IF NOT EXISTS SafetyAlertResponse (
    ResponseID INTEGER PRIMARY KEY NOT NULL,
    AlertID INTEGER NOT NULL,
    SupportStaffID TEXT NOT NULL,
    ResponseDescription TEXT NOT NULL,
    ResponseDateTime TEXT NOT NULL,

    FOREIGN KEY (AlertID) REFERENCES SafetyAlert(AlertID),
    FOREIGN KEY (SupportStaffID) REFERENCES SupportStaff(UserID)
);
CREATE TABLE IF NOT EXISTS SupportRequest (
    SupportRequestID INTEGER PRIMARY KEY NOT NULL,
    UserID TEXT NOT NULL,
    AssignedStaffID TEXT,
    RequestType TEXT NOT NULL,
    RequestDesc TEXT NOT NULL,
    SubmissionDate TEXT NOT NULL,
    RequestStatus TEXT NOT NULL
        CHECK (RequestStatus IN (
            'open', 'in_progress', 'resolved', 'closed'
        )),
    Notes TEXT,

    FOREIGN KEY (UserID) REFERENCES User(UserID),
    FOREIGN KEY (AssignedStaffID) REFERENCES SupportStaff(UserID)
);
CREATE TABLE IF NOT EXISTS "SupportStaff" (
	"UserID"	TEXT NOT NULL,
	"EmployeeID"	TEXT NOT NULL UNIQUE,
	"StaffRole"	TEXT NOT NULL,
	PRIMARY KEY("UserID"),
	FOREIGN KEY("UserID") REFERENCES "User"("UserID")
);
CREATE TABLE IF NOT EXISTS "User" (
	"UserID"	TEXT NOT NULL,
	"Password"	TEXT NOT NULL,
	"FullName"	TEXT NOT NULL,
	"PhoneNum"	TEXT NOT NULL,
	"Street"	TEXT NOT NULL,
	"ZipCode"	TEXT NOT NULL,
	"RegistrationDate"	TEXT NOT NULL,
	"AccountStatus"	TEXT NOT NULL CHECK("AccountStatus" IN ('active', 'suspended', 'deactivated')),
	PRIMARY KEY("UserID"),
	FOREIGN KEY("ZipCode") REFERENCES "ZipCode"("ZipCode")
);
CREATE TABLE IF NOT EXISTS Vehicle (
    VehicleID INTEGER PRIMARY KEY NOT NULL,
    DriverID TEXT NOT NULL,
    Make TEXT NOT NULL,
    Model TEXT NOT NULL,
    Year INTEGER NOT NULL,
    LicensePlate TEXT NOT NULL UNIQUE,
    VehicleColor TEXT NOT NULL,
    VehicleCapacity INTEGER NOT NULL CHECK (VehicleCapacity > 0),

    FOREIGN KEY (DriverID) REFERENCES Driver(UserID)
);
CREATE TABLE IF NOT EXISTS ZipCode (
    ZipCode TEXT PRIMARY KEY NOT NULL,
    City TEXT NOT NULL,
    State TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS Zone (
    ZoneID INTEGER PRIMARY KEY NOT NULL,
    ZoneName TEXT NOT NULL UNIQUE
);
CREATE TABLE IF NOT EXISTS ZoneZipCode (
    ZipCode TEXT PRIMARY KEY NOT NULL,
    ZoneID INTEGER NOT NULL,

    FOREIGN KEY (ZipCode) REFERENCES ZipCode(ZipCode),
    FOREIGN KEY (ZoneID) REFERENCES Zone(ZoneID)
);
COMMIT;
