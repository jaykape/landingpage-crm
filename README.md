# LandingPage-CRM

A simple project designed to collect leads from a static landing page, store them in a SQL database and manage them through a secure web-based UI CRM with access control for different user roles.

---

## :factory: Main Components

- **Static Landing Page**
  - Hosted on S3
  - Collects First Name, Last Name, Email, and Phone Number
  - Sends data to backend via API Gateway

- **SQL Database**
  - PostgreSQL on Amazon RDS
  - Stores submitted leads

- **CRM Web UI (Upcoming)**
  - Interface to view, search, and manage leads
  - User accounts with different permission levels (Admin, Sales)

---

## :hammer: Current Status

- [x] Initial infrastructure with Terraform (S3, RDS, Lambda, API Gateway)
- [x] HTML form and API connection
- [ ] Database (PostgreSQL)
- [ ] CRM Web UI with role-based access control

---

Feel free to open issues or submit PRs. Suggestions welcome!
