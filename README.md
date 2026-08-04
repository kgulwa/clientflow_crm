# ClientFlow CRM

A modern CRM built with Ruby on Rails for managing clients, leads, deals, contacts, tasks, notes, and business reporting.

## Overview

ClientFlow CRM is a customer relationship management application built with Ruby on Rails. It provides businesses with a single workspace to manage clients, leads, sales opportunities, contacts, follow-ups, notes, and reporting.

The project focuses on building a responsive, modern Rails application using Hotwire, Turbo, Tailwind CSS, PostgreSQL, and RSpec while following MVC architecture and RESTful design principles.

## Features

### Authentication

- Secure user registration
- User login
- Password reset
- Password visibility toggle
- Session management

### Dashboard

- Business overview
- Client statistics
- Lead summary
- Recent leads
- Upcoming tasks
- Quick actions

### Client Management

- Create clients
- Edit clients
- Delete clients
- Client search
- Status filtering
- Pagination
- CSV export

Each client includes:

- Contacts
- Tasks
- Notes
- Tags
- Activity timeline
- Client summary

### Contact Management

- Multiple contacts per client
- Primary contact support
- Job titles
- Departments
- Email and phone information

### Lead Management

- Create leads
- Edit leads
- Track lead status
- Track acquisition source
- Search and filtering
- CSV export

### Deal Pipeline

- Create sales opportunities
- Deal stages
- Expected close dates
- Deal values
- Client association

### Task Management

- Create client tasks
- Priority levels
- Due dates
- Status tracking
- Global task dashboard

### Notes

- Client notes
- Timeline history
- Follow-up tracking

### Tags

- Create reusable tags
- Assign tags to clients
- Color-coded organization

### Reporting

Business overview dashboard including:

- New clients
- Closed deals
- Revenue
- Conversion rate
- Completed tasks
- Monthly revenue summary

### Exporting

- Export Clients to CSV
- Export Leads to CSV

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

## Running Locally

```bash
git clone https://github.com/kgulwa/clientflow_crm.git

cd clientflow_crm

bundle install

rails db:create
rails db:migrate
rails db:seed

bin/dev
```

## Running Tests

```bash
bundle exec rspec
```

## Future Improvements

- Email reminders
- Calendar integration
- File attachments
- Activity notifications
- Charts and analytics
- Mobile optimization
- API endpoints
- Team collaboration
- Role-based permissions
