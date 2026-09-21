---
layout: default
title: Mentoring Manager checklist
eyebrow: Post-setup · Role
summary: For programmes coordinators and entrepreneur-in-residence coordinators running mentoring opportunities and mentor selection.
permalink: /roles/mentoring-manager/
---

## Permission sets

<ul class="contains-task-list">
  <li class="task-list-item"><input type="checkbox" disabled> <code>Technology_Transfer_Starter_Permission</code> (base).</li>
  <li class="task-list-item"><input type="checkbox" disabled> <strong>+ <code>Technology_Transfer_Starter_Mentoring_Manager</code></strong> — the Mentoring Manager app plus Mentoring Opportunity and Mentoring Interest objects.</li>
</ul>

## Fields to add to layouts

| Object | Field | Add? |
| --- | --- | --- |
| Mentoring Opportunity | `Total_Selected_Interests__c` | Optional (roll-up summary) |

All other mentoring fields are on the default Mentor and Mentee layouts.

## Automation

<ul class="contains-task-list">
  <li class="task-list-item"><input type="checkbox" disabled> Confirm <code>TTS_Mentoring_Set_Chosen_Mentor_on_Opportunity</code> (Active) runs — it sets the chosen mentor on the opportunity when an interest is selected.</li>
</ul>

## Configuration

<ul class="contains-task-list">
  <li class="task-list-item"><input type="checkbox" disabled> Review the mentoring <strong>expertise</strong> and <strong>status</strong> picklists to match your programme.</li>
  <li class="task-list-item"><input type="checkbox" disabled> Confirm the Mentor and Mentee record pages/layouts suit how your coordinators work.</li>
  <li class="task-list-item"><input type="checkbox" disabled> Decide who ranks interests and selects mentors, and set sharing accordingly.</li>
</ul>
