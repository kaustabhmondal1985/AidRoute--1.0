# Urgency Definitions

## Purpose

This document defines the general urgency levels used by AidRoute for legal-aid intake triage.

Urgency classification is intended to prioritize human review.

It is not a legal conclusion.

## Low Urgency

A case may be considered low urgency when:

- No immediate deadline is identified
- No imminent hearing is identified
- No immediate time-sensitive action is apparent
- The available information does not indicate a need for prompt review

Low urgency does not mean that the case is unimportant.

## Medium Urgency

A case may be considered medium urgency when:

- The matter is important but no immediate deadline is identified
- A future action may require attention
- Some information suggests that timely review would be useful
- The situation requires additional information before urgency can be determined

## High Urgency

A case may be considered high urgency when approved intake criteria indicate a need for prompt human review.

Potential indicators include:

- Imminent deadline
- Imminent court date
- Current detention
- Immediate risk of losing housing
- Official notice requiring prompt action
- A time-sensitive date extracted from an uploaded document

High urgency means:

"Human review should be prioritized."

It does not mean that the system has determined the legal outcome.

## Deadline-Based Assessment

When a reliable date is detected:

1. Identify the date.
2. Identify what the date represents.
3. Compare the date with the current date.
4. Check whether an approved urgency guideline applies.
5. Use the guideline to support the urgency assessment.

The system must not invent a deadline.

## Missing Information

If the system cannot determine whether a case is urgent because important information is missing:

- Ask for relevant information when appropriate.
- Do not assume a deadline.
- Do not invent urgency criteria.
- Consider human review when uncertainty remains.

## Low Confidence

If urgency cannot be reliably determined:

urgency = unknown

requires_human_review = true

The system should explain that the available information was insufficient for a reliable automated assessment.

## Re-Triage

Urgency must be reassessed when new relevant information becomes available.

Examples include:

- A document is uploaded
- A deadline is extracted
- A court date is discovered
- The user provides a previously missing date
- The case category changes

Previous urgency:

MEDIUM

New evidence:

Deadline detected

After reassessment:

HIGH