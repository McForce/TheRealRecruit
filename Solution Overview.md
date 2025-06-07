Salesforce Recruitment Applicant Tracking System (ATS)
Technical Architecture Documentation

1. Introduction & Objectives
This document describes the technical architecture and solution design for a Recruitment Applicant Tracking System (ATS) built on Salesforce. The ATS automates the end-to-end process of candidate management, from CV ingestion and parsing to AI-powered job matching and application status updates.

2. Solution Architecture Overview

Key Components:
Data Cloud Triggered Flow: Initiates processing when a CV (PDF) is uploaded.
Candidate Object: Central entity representing applicants.
AI Grounding & Analysis Flows: Use of Salesforce AI and custom agents to extract and validate candidate data.
Application Update Automation: Streamlines application status changes and notifications.

3. Key Flows and Processes
CV Parsing and Candidate Matching
CV Upload (UDMO Record Creation):
Recruiter uploads a CV (PDF), creating a UDMO record.
Data Cloud Triggered flow:
A flow is triggered to process the new record and create a Candidate object.
AI Grounding Screen:
Validates and enriches candidate data using Salesforce AI tools.
Prompt Invocable Agent:
Initiates the Search CV Agent Action to locate and analyze the CV.
CV Analysis:
Runs an AI-powered prompt to extract data (skills, experience, etc.).
Candidate Record Update:
Updates Candidate object fields based on analysis results.
Job Matching:
Invokes Agent Action to match the candidate to open jobs, using AI and business rules.
Application Update:
Automates updating of related Application records and notifies stakeholders.

4. Technical Deep Dive
Data Model
UDMO (Unstructured Data Model Object) (CV Record): Stores uploaded CVs.
Candidate: Custom object storing candidate data.
Application: Junction object that Links candidates to job Spec’s.
Job Spec: Custom object to store the job specification data
Integration Points
Salesforce Data Cloud: For scalable data ingestion and eventing.


5. Value Delivered
Reduces manual effort for recruiters via automation.
Improves candidate experience through faster response times.
Enhances job-candidate matching using AI-driven insights.

