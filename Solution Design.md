Solution Design: Job Spec Search Candidates (AI-Driven Candidate Search in Salesforce ATS)
1. Overview
This section describes the technical design for the AI-powered function that finds the most applicable candidates for a given Job Spec within the Salesforce Applicant Tracking System (ATS). This genAIFunction leverages AI prompt orchestration to search and rank candidates based on their suitability for an open job requisition.

2. Key Component
2.1 Job_Spec_Search_Candidates GenAIFunction
File: genAiFunctions/Job_Spec_Search_Candidates/Job_Spec_Search_Candidates.genAiFunction-meta.xml
Purpose:
AI-driven search to identify and surface the most suitable candidates for a specific Job Spec. The process leverages AI to analyze candidate records and match them to the requirements and preferences of the job spec.
Invocation Target:
Type: generatePromptResponse (AI prompt, not a flow)
Name: Job_Spec_Search_Candidates
User Experience:
No explicit user confirmation is required to execute the search.
A progress indicator ("Searching Database") is shown while the process runs, improving UX for potentially long-running or complex searches.
Description Excerpt:
Find the most applicable Candidates for this Job

3. Process Flow
Input:
The genAIFunction receives the Job Spec as its primary context.
AI Processing:
The AI agent analyzes the Job Spec’s requirements, preferences, and qualifications.
It searches the candidate database (within Salesforce context, or via integrated AI) to identify candidates who best match the job spec.
Output:
Ranked or filtered list of candidates most suitable for the job.
Output may include details such as candidate fit, missing requirements, or summary explanations, depending on prompt/template configuration.
User Feedback:
While the AI is searching, users see "Searching Database" as a progress message.
Results are displayed with no need for further confirmation or manual steps.
In Essence: This solution enables recruiters to leverage AI for rapid, standardized candidate identification and ranking based on job requirements, improving both speed and quality of the hiring process.


1. AI Grounding RTF Flow: Component Overview and Execution Order
Type: Auto-launched Flow (triggered by Data Cloud data changes)
1. Trigger/Event
Triggered when: A new record is created in the AiGroundingFileRefCustom__dlm object, via a Data Cloud data change event.
2. Record Lookup
Step: Get_Candidate
What it does: Looks up a Candidate__c record where CV_Title__c equals the Name__c of the triggering record (AiGroundingFileRefCustom__dlm). It retrieves the first matching record.
3. Action Call: Search CV
Step: Search_CV
What it does: Calls the Apex Invocable action Agentforce_Recruitment_Agent_Invokable with the action type generateAiAgentResponse.
Parameter: Sends a prompt (generated from the candidate's email) asking to "bring up my CV my email address is {email}".
Purpose: Likely interacts with an AI agent to locate and analyze the candidate's CV based on their email address.
4. Action Call: Update Record
Step: Update_Record
What it does: Calls the same Apex Invocable action, passing along the sessionId from the previous step and a prompt "Please update my record".
Purpose: Instructs the AI agent to update the candidate record, possibly with new information extracted from the CV.
5. Flow Variables & Templates
Formulas/Text Templates: Used to dynamically compose prompts and messages for the AI agent (e.g., extracting the candidate's email, formatting requests).
Session Management: The flow passes a sessionId between steps to maintain context with the AI agent.


2. CV Analysis Prompt (Agentforce genAIFunction)
1. Trigger and Invocation
The flow (AI Grounding RTF) triggers the Agentforce action, invoking the genAIFunction named CV_Analysis_Prompt.
2. Prompt Template and Function
Prompt Template: CV_Analysis_Prompt.genAiPromptTemplate-meta.xml
This template instructs the AI to analyze a candidate’s CV in detail, categorizing data into sections (qualifications, experience, education, skills, languages, etc.).
It uses the candidate’s email (from the flow) to search and retrieve the relevant CV via Salesforce Einstein’s retriever.
The AI is instructed to present the entire CV (not just a summary) and only generate a short overview in its own words.
Function Metadata: CV_Analysis_Prompt.genAiFunction-meta.xml
Describes the function’s purpose: to extract and categorize all relevant CV data for later population in a Candidate record.
The function is invoked as generatePromptResponse and does not require confirmation or a progress indicator.
3. Input and Output Schema
Input: Expects a string input representing the CV library (i.e., an email or identifier to locate the CV).
Output: Returns the full prompt response (the CV as found plus a generated overview) and any citations from the retrieval process.
4. Plugin and Orchestration
Plugin: Candidate_CV_Search.genAiPlugin-meta.xml
Orchestrates when and how the CV Analysis Prompt is used in conversation.
Ensures the candidate’s email is used to fetch the correct CV document.
Directs the agent to bring up the entire CV and then prompt to update the candidate’s profile.
5. What It Does in the Flow
After a Data Cloud-triggered event, the system:
Looks up the candidate using the email or another identifier.
Invokes the CV Analysis Prompt genAIFunction.
The AI fetches the CV, analyzes it, and returns structured information and a short overview.
This response can then be used to update the Salesforce Candidate record automatically or after user confirmation.


In essence:
The CV Analysis Prompt genAIFunction is a core AI-driven automation step, extracting comprehensive candidate data from CVs and feeding it into your ATS flows for further processing and record updates—all orchestrated through metadata-driven configuration in Salesforce.


3. Candidate Record Update Agent Action (genAIFunction)
Purpose
This agent action is responsible for updating the Salesforce Candidate__c record with all relevant data parsed from the candidate's CV, using information extracted by the previous AI analysis steps.
How it Works
1. Plugin Orchestration
The Candidate_Record_Update plugin defines the process:
Find the correct Candidate__c record using email or record ID.
Use the AI-extracted information from the CV (from the Candidate CV Search/Prompt actions).
Confirm with the user (candidate or recruiter) if they want to update the profile.
If confirmed, proceed to update the record.
2. genAIFunction Execution
The main function (e.g., Update_Candidate_3 or Update_Candidate) is invoked, typically by a flow or agent.
The function:
Accepts the Candidate record ID and CV-derived data as input.
Populates all relevant Candidate fields with extracted CV values.
Key fields updated include: Name, Email, Address, Phone, Career Title, Career Goals, Certifications, Skills, Languages, Work History/Professional Experience, Education, Date of Birth, and Social links.
The "Summary" field is generated by the AI as a human-readable overview, starting with total years of experience.
3. Field Mapping
The AI function and flows map rich and structured data from the CV to the respective Salesforce fields:
Example fields: Career_Title__c, Seniority_Level__c, Certifications__c, Education__c, Skills__c, Work_History__c, Languages__c, Summary__c, etc.
Follows strict instructions to only use CV data for all fields except the summary, which may be paraphrased.
4. Automation and Flows
The flows (e.g., Update_Candidate_after_qs, Update_Candidate) handle the record lookup and update steps:
Lookup Candidate by email.
Assign parsed values to each field.
Update the record in Salesforce, marking it as AI-updated if applicable.

Example of the Update Process
Agent receives command to update candidate.
Looks up Candidate__c record by email or ID.
Maps extracted CV data to fields:
Career Title, Goals, Work History, Certifications, Education, Skills, Languages, Address, Social links, DOB, etc.
AI generates a professional summary.
Saves updates to the Candidate__c record.
Optional: Confirms with the user if changes should be applied, then completes the update.

In essence:
The Candidate Record Update agent action turns all the rich, structured data extracted from the candidate’s CV into a fully-populated, up-to-date Candidate__c record in Salesforce—automatically and with minimal manual input, ensuring data accuracy and completeness for downstream ATS processes.


4. Update Application RTF Flow: Component Overview and Execution Order
Type: Auto-launched Flow (triggered by Candidate record update)
1. Trigger/Event
When: The flow is triggered when a Candidate__c record is updated and the field AI_Updated_Fields__c is set to true.
How: It uses a scheduled path to wait 1 minute after the record is updated before proceeding.
2. Record Lookups
Get Applications: Looks for the first Application__c record where Status__c is "New" and Candidate__c matches the triggering record.
Get Job Spec: Fetches the related Job_Spec__c for the application.
4. Action Calls (AI Agent Invocations)
Invoke Search CV:
Calls the AI agent with a prompt to match the candidate to the job spec.
Uses a dynamic template: "Can you match the candidate (Candidate recordID: X) to the job spec they applied for (Job Spec ID: Y)..."
Update Application:
Uses the sessionId from the previous step.
Prompts the agent: "Please update the Application record."
Prompts the agent to update the candidate record with academic transcript data.

5. Templates and Variables
Userinputtemplate: Dynamic text template used to provide context to the AI agent for matching.

In essence:
This flow automates the process of matching candidates to job specs and updating application records, leveraging AI agents for both CV/application and (for graduates) academic transcript analysis. It ensures applications are updated promptly and accurately after candidate data is enriched by AI.


5. Update Application Auto 5.0 Agent Action (GenAIFunction)
Purpose
This AI agent action is designed to analyze the candidate and their application, matching them to the relevant job specification (Job_Spec__c) they applied for, and automatically populating critical application fields using AI-driven analysis.
Key Features
Automated Application Assessment:
The agent reviews the Candidate__c and Job_Spec__c data for the application and performs an intelligent fit/gap analysis.
Populates Key Application Fields:
Application Rating: AI assesses how well the candidate matches the job requirements.
Overview of Applicant: AI generates a human-readable summary of the candidate for the application.
What Makes Applicant a Good Fit: AI identifies and documents strengths and matches between candidate and job spec.
What Requirements/Skills are Missing: AI highlights any gaps or missing qualifications the candidate has relative to the job requirements.
Flow Invocation:
The genAIFunction is invoked as a flow action, meaning it can be triggered as part of automated Flow orchestration after candidate and application record enrichment.
No Confirmation Required:
The action is non-interactive and runs to completion without requiring further user input.
Technical Metadata
Function Metadata:
invocationTarget: Update_Application_Auto (a flow or Apex process)
invocationTargetType: flow
masterLabel: "Update Application Auto 5.0"
Description:
Executes the Update Application prompt, analyzing the candidate and matching them to the job spec, specifically focusing on rating, overview, fit, and gap fields.

In essence:
The "Update Application Auto 5.0" agent action brings end-to-end automation to the application screening process, ensuring every application is objectively rated and summarized, with clear strengths and gaps identified—supporting faster and more data-driven hiring decisions.


6. Update Application Auto Flow
Type: Auto-Launched Flow
File: Update_Application_Auto.flow-meta.xml
Steps:
Candidate Lookup
Looks up Candidate__c record by RecordId.
Application Lookup
Retrieves the related Application__c record where Status__c = 'New' and Candidate__c matches.
Job Spec Lookup
Fetches the corresponding Job_Spec__c record from the application.
AI Assessment Invocation
Calls the genAIFunction Update_Application_Prompt (see below), passing in the Application record.
Receives structured AI output including fit/gap analysis, summary, and rating.
Mapping/Output Handling
Flow variables include: GoodFit, BadFit, Overview, Rating, NonNegotiables, and others, for downstream use or record updating.

7.  Update Application Prompt (genAiPromptTemplate)
Type: GenAI Prompt Template
File: Update_Application_Prompt.genAiPromptTemplate-meta.xml
Purpose:
To instruct the AI to act as a specialist recruiter, analyze the candidate and job spec, and provide a standardized assessment.
Key Instructions to AI:
Analyze candidate’s Education, Seniority, Certifications, Skills, Languages, etc.
Compare against the Job Spec’s requirements and non-negotiables.
Output the following:
Application Rating: Score out of 10 for the job spec.
Overview of Candidate: Years of experience, job history, and summary of suitability.
Good Fit Analysis: Explicit reasons the candidate matches the job.
Missing Requirements/Skills: Explicit gaps for this application.
Non-Negotiables Check: Does candidate meet all? If not, what’s lacking?
Input: Full Application__c SObject, with candidate and job spec subfields.
Primary Model: Typically GPT-4 or GPT-4 Turbo, depending on org configuration.
Example Prompt Block:
As a specialist recruiter, you will analyze the Candidate: {!$Input:Application.Candidate__r.Id}, compare their Education {!$Input:Application.Candidate__r.Education__c}, Seniority Level, Certifications, Skills, and Languages to the Job Spec requirements.

You will then answer:
- Application Rating: What would you score the applicant out of ten for this Job Spec?
- Overview of Candidate: Short overview with years of experience, job history, and highlights.
- Good Fit: What makes applicant a good fit for this job?
- Missing Skills: Where is the candidate possibly lacking?
- Non-Negotiables: Does candidate meet all? If not, what is missing?



In Essence: This solution automates application assessment, delivering consistent, unbiased, and rapid candidate-job matching. Recruiters benefit from standardized summaries and fit/gap analysis, while the organization gains increased efficiency and decision support in hiring.


8. Update Application Final Auto 2.0 (AI-Driven Application Finalization in Salesforce ATS)
1. Overview
This section describes the technical solution for the final automated application processing in the Salesforce Applicant Tracking System (ATS). This part of the automation pipeline ensures all application records are fully enriched, validated, and have their key status fields set based on AI analysis, business logic, and compliance requirements.

2. Key Components
2.1 Update_Application_Final_Auto_2 GenAIFunction

Purpose:
This is a genAIFunction that acts as the orchestrator for the final application update. It takes the AI analysis from the matching prompt (comparing Candidate__c to Job_Spec__c) and uses it to update the Application__c record with all relevant fields and statuses.
Invocation Target:
Type: Flow
Name: Update_Application_Final_Auto
No Confirmation or Progress Required:
Runs silently and to completion.
Description Excerpt:
This action will be taking the input from the Update application Prompt that is analyzing the Candidate__c and matching them to the Job_Spec__c that they applied for and then update the Application record with the relevant fields.

2.2 Update Application Final Auto Flow
File: flows/Update_Application_Final_Auto.flow-meta.xml
Flow Steps and Logic:
Start:
Flow is auto-launched, likely triggered by upstream application updates or after AI analysis is available.
Candidate & Application Lookup:
Looks up Candidate__c by recordId.
Finds the first "New" status Application__c for that candidate.
Fetches the corresponding Job_Spec__c.
Branching by Candidate Type:
Full Time:
Updates the application with assessment output fields (see below), then checks "Non Negotiables" response.
If candidate meets non-negotiables, moves status to "Qualifying questions".
If not, sets status to "Unsuccessful".
Graduate:
Updates additional graduate-specific application fields (e.g., Matric Results, SAICA contract, family at PWC, preferred office, etc.) in addition to standard assessment output.
Still checks and records non-negotiables.
Field Updates:
For All Candidates:
Application_Rating__c ← AI Rating
Non_Negotiables__c ← AI Non-Negotiables response
Overview_of_applicant__c ← AI Overview
What_makes_applicant_a_good_fit__c ← AI GoodFit
What_requirements_Skills_missing__c ← AI BadFit
Status Handling:
If candidate meets non-negotiables, moves application status to "Qualifying questions".
If not, marks application as "Unsuccessful".


In Essence:
This solution ensures the final application record is fully and consistently updated using both automated AI analysis and flow-based business rules. It supports both full-time and graduate hiring pipelines, and guarantees key status fields and fit/gap assessments are always present for recruiter and system use.


10. Solution Design: Application Questions and Answers Auto (AI-Driven Q&A for Applications in Salesforce ATS)
1. Overview
This section describes the technical design for automatically generating and handling candidate-specific and job-specific questions and answers during the application process in Salesforce ATS. This is achieved using a genAIFunction that orchestrates the generation of questions based on both job requirements and candidate profile, and updates the application record with the results.

2. Key Component
2.1 Application_Questions_and_Answers_Auto GenAIFunction
File: genAiFunctions/Application_Questions_and_Answers_Auto/Application_Questions_and_Answers_Auto.genAiFunction-meta.xml
Purpose:
To ask the candidate questions as specified by the Job_Spec__c's Questions_And_Answers__c and Candidate_Specific_Questions__c fields, collect their responses, and update the Application__c record accordingly.
Invocation Target:
Type: Flow
Name: Application_Questions_and_Answers_Auto
User Experience:
No explicit user confirmation is required.
Progress indicator shows "Thinking of questions to Ask" to the user while the AI is generating and managing the questions/answers.
Description Excerpt:
This action is used to ask the Candidate__c questions per the Job_Spec__c's Questions_And_Answers__c field and Candidate_Specific_Questions__c field. and then update the Application record with the answers.

3. Process Flow
Input:
The function receives references to both the Candidate and the Job Spec.
AI Processing:
AI generates relevant questions for the candidate based on both:
The job's predefined questions (Questions_And_Answers__c)
Any candidate-specific questions (Candidate_Specific_Questions__c)
Presents these questions to the candidate (directly or through a flow-driven UI).
Collects and structures candidate responses.
Update:
Updates the Application__c record with questions, answers, and any derived insights.
User Feedback:
Progress indicator is displayed during question generation and answer handling.
In essence: This solution enables automation of dynamic, targeted Q&A during the application process, improving both candidate experience and data quality for recruiters.

Solution Design: Email to Hiring Manager (AI-Driven Candidate Summaries for Hiring Manager Outreach)
1. Overview
This solution describes the orchestration of generating, reviewing, and sending a summary email to a hiring manager that includes a concise overview of candidates who have applied to a job spec. It leverages a Salesforce Flow for orchestration and a genAI prompt template for generating the candidate summary email content.

2. Key Components
2.1 Email to Hiring Manager SF Flow
File: flows/Email_to_Hiring_Manager_SF.flow-meta.xml
Purpose:
To automate the generation, review, and sending of a candidate summary email to the hiring manager, and to update the corresponding job spec status.
Flow Steps:
Start:
The flow is triggered (can be user-initiated or part of a larger automation).
AI-Powered Email Generation:
Calls the Email_To_Hiring_Manager genAI prompt template via the generatePromptResponse action.
Passes the Job_Spec record as context.
User Review Screen:
Displays an editable screen for the user to review and edit the generated email (subject and body).
Shows the recipient (hiring manager), subject, and email body with the AI-generated content.
Send Email:
Utilizes the emailSimple action to send the email to the hiring manager's email address.
Subject and body can be user-modified before sending.
Update Job Status:
Updates Job_Spec__c.Status__c to "Candidates to be reviewed by Hiring Manager" to indicate the next stage of the process.
Templates and Variables:
Uses text templates to compose the email subject and body, pulling from the AI output and Job Spec fields.
Variables include the Job_Spec SObject and fields for email composition.

2.2 Email To Hiring Manager genAiPromptTemplate
File: genAiPromptTemplates/Email_To_Hiring_Manager.genAiPromptTemplate-meta.xml
Purpose:
To instruct the AI to generate a clear, concise, and actionable candidate summary email for the hiring manager, based on the Job Spec and the list of candidates who applied.
Input:
Job_Spec SObject, including job title, hiring manager name, and a data provider (Get_Candidates_That_Applied_Prompt) for candidate details.
Prompt Instructions:
Use clear, concise, and straightforward language.
Generate a subject line: Job title [Job Title] Candidates.
Structure the email body as follows:
Title with the Job Spec name.
Greet the hiring manager by name.
Intro paragraph explaining that candidates have been qualified.
List each candidate: name, current title, years of experience, current company, rating.
For each candidate, include an overview and analysis of fit (good/bad match).
Provide a link to the Job Spec for the hiring manager to review applications.
(Optional) Closing from the recruiter.
All candidate summaries and details are provided via the supporting flow.
Primary Model:
Model may vary (e.g. GPT-4 Turbo, Omni, or Claude3), but always generates a complete, ready-to-send email.
In essence: This solution streamlines communication between recruiters and hiring managers, ensuring that candidate summaries are clear, actionable, and consistently formatted. The combination of Salesforce Flow orchestration and AI-driven content generation enables rapid, accurate, and professional outreach at scale.
