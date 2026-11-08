CREATE TABLE EmailChangeRequest (
    EmailChangeID INTEGER PRIMARY KEY NOT NULL,
    UserID TEXT NOT NULL,
    ProposedEmail TEXT NOT NULL UNIQUE,
    ReviewedBy TEXT,
    RequestDate TEXT NOT NULL,

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
CREATE TABLE RegistrationApproval (
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