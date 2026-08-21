# ClientFlow CRM

A full-stack customer relationship management application independently designed and built with Ruby on Rails, PostgreSQL, Hotwire, Tailwind CSS, and RSpec.

ClientFlow helps teams manage clients, leads, sales opportunities, contacts, tasks, communication, and business reporting within shared workspaces.

## Project Highlights

- Multi-user workspace architecture with workspace-level data isolation
- Role-based workspace membership and invitations
- Client, lead, contact, deal, task, note, and tag management
- Task assignment between workspace members
- In-app and email notifications
- Revenue and client-growth reporting
- Search, filtering, pagination, and CSV exports
- Dynamic interactions using Hotwire, Turbo, and Stimulus
- Secure authentication and account management with Devise
- Comprehensive automated test suite
- 474 RSpec examples with 0 failures
- 93.30% line coverage

## Screenshots

> Screenshots of the live application will be added here.

Recommended views:

- Dashboard
- Client management
- Deal pipeline and tasks
- Reporting dashboard
- Workspace and account settings

## Features

### Authentication & Account Management

- Secure user registration and login
- Password reset
- Password changes
- Profile and email management
- Account deactivation
- Session management

### Workspaces & Team Collaboration

- Workspace-based CRM accounts
- Workspace invitations
- Admin and member roles
- Workspace member management
- Task assignment between members
- Workspace-level data isolation

### Dashboard

- Client statistics
- Lead pipeline summary
- Leads by status
- Deal pipeline by stage
- Open pipeline value
- Recently added clients
- Overdue tasks
- Upcoming tasks
- Quick actions

### Client Management

- Create, view, edit, and delete clients
- Client search
- Status filtering
- Pagination
- CSV export
- Client summary
- Activity timeline
- Contacts
- Tasks
- Notes
- Tags

### Contact Management

- Multiple contacts per client
- Primary contact support
- Job titles and departments
- Email and phone information

### Lead Management

- Create, view, edit, and delete leads
- Lead status tracking
- Acquisition source tracking
- Search and filtering
- CSV export

### Deal Pipeline

- Sales opportunity management
- Deal stage tracking
- Expected close dates
- Deal values
- Client associations
- Pipeline value reporting

### Task Management

- Client task management
- Task assignment to workspace members
- Priority levels
- Due dates
- Status tracking
- Overdue task tracking
- Global task dashboard

### Notifications

- In-app notifications
- Notification dropdown
- Read and unread states
- Clickable notification destinations
- Email notification delivery

### Notes & Tags

- Client notes
- Follow-up history
- Reusable tags
- Client tag assignment
- Color-coded organization

### Reporting

- Custom date-range reporting
- New client totals
- Closed deals
- Revenue
- Conversion rate
- Completed tasks
- Monthly revenue trends
- Yearly revenue
- Average monthly revenue
- Best revenue month
- Monthly client growth
- Average monthly client growth
- Best client-growth month
- Historical year selection

### Data Export

- Client CSV exports
- Lead CSV exports

## Architecture

ClientFlow follows Rails MVC architecture and RESTful design principles.

The application uses a workspace-based architecture that allows multiple users to collaborate on the same CRM data while keeping records isolated between workspaces.

A newly registered user receives a workspace and administrator role. Additional users can be invited into the workspace as members, allowing teams to collaborate on shared clients, leads, deals, tasks, and other CRM records.

### Core Relationships

- Workspace → Users
- Workspace → Clients
- Workspace → Leads
- Client → Contacts
- Client → Deals
- Client → Tasks
- Client → Notes
- Client ↔ Tags
- User → Assigned Tasks
- User → Notifications

This architecture provides a foundation for multi-user collaboration while preventing users from accessing data belonging to other workspaces.

## Tech Stack

### Backend

- Ruby
- Ruby on Rails
- PostgreSQL

### Frontend

- Hotwire
- Turbo
- Stimulus
- Tailwind CSS

### Authentication

- Devise

### Testing

- RSpec
- Capybara
- FactoryBot
- SimpleCov

## Testing & Quality

ClientFlow includes automated model, request, and application-level tests covering the core CRM functionality.

Current test suite:

```text
474 examples
0 failures
1 pending
93.30% line coverage
```

The test suite covers areas including:

- Authentication and registration
- Account management
- Workspace data isolation
- Workspace invitations and member management
- Client management
- Lead management
- Contacts
- Deals
- Tasks and task assignment
- Notifications
- Reporting
- CSV exports

## Running Locally

### Requirements

Ensure Ruby, PostgreSQL, and the required Rails dependencies are installed.

Clone the repository:

```bash
git clone https://github.com/kgulwa/clientflow_crm.git
cd clientflow_crm
```

Install dependencies:

```bash
bundle install
```

Create and prepare the database:

```bash
rails db:create
rails db:migrate
rails db:seed
```

Start the application:

```bash
bin/dev
```

## Running Tests

Run the complete RSpec test suite:

```bash
bundle exec rspec
```

Generate the SimpleCov coverage report by running the test suite, then open:

```text
coverage/index.html
```

## Project Status

**ClientFlow v1 is feature-complete.**

The current version provides a complete CRM workflow covering authentication, multi-user workspaces, client and lead management, contacts, deal tracking, task collaboration, notifications, reporting, and data exports.

The project remains open to future enhancements, but the core application is complete and fully usable as a standalone CRM.

## Potential Future Enhancements

- Calendar integration
- File attachments
- Interactive reporting charts
- Public API endpoints
- Advanced role and permission controls

## Author

**Konke Gulwa**

ClientFlow CRM was independently designed, developed, tested, and refined as a full-stack Ruby on Rails project.
