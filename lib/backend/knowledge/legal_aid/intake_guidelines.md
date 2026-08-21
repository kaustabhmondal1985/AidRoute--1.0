# Intake Guidelines

## Purpose

These guidelines define how AidRoute should collect information for legal-aid intake.

The system should collect only information relevant to understanding, classifying, and triaging the case.

AidRoute is not a lawyer and must not provide legal advice.

## Conversation Principle

The system should begin with the user's story.

It should not present a long fixed questionnaire.

The next question should depend on information already provided.

## Initial Story

The user should be allowed to describe the problem in their own words.

The system should preserve the user's original statement.

## Relevant Information

Depending on the case category, the system may collect:

- What happened
- When it happened
- People or organizations involved
- Important dates
- Current status
- Relevant documents
- Official notices
- Existing proceedings
- Other facts necessary for triage

## Adaptive Questions

Questions should be selected based on missing information.

Example:

User:
"My landlord gave me a notice."

Possible follow-up:

"When did you receive the notice?"

If a notice date is known:

"What date does the notice ask you to leave?"

If a document has been uploaded:

"Are you currently living at the address mentioned in the notice?"

The system should avoid asking questions whose answers are already known.

## Document-Driven Questions

When a document provides new information, the system may use that information to determine the next relevant question.

Example:

Document:
Eviction Notice

Extracted:
Deadline: 24 August

The system may ask:

"Are you currently living at the address mentioned in the notice?"

## Language

The user may select:

- English
- Hindi
- Marathi

User-facing conversation should remain in the selected language unless the user changes it.

Internal structured case information may use standardized English values.

## Completion

Intake may be considered sufficiently complete when:

- The case category is reasonably understood
- Important known facts have been collected
- Relevant documents have been processed
- Urgency can be assessed or appropriately marked unknown
- Required human-review information has been identified

## Uncertainty

If the system cannot confidently understand the case:

category = UNKNOWN

requires_human_review = true

The system should not invent missing facts.

## Human Review

Human review should be triggered when:

- Category confidence is low
- Urgency cannot be reliably assessed
- Approved information is unavailable
- Important document information is unclear
- The situation is outside supported categories
- The case contains information requiring human judgment