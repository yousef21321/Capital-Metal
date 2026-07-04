export const TICKET_STATUS = {
  pending_tester_review: { label: 'Pending Tester Review', color: 'warning' },
  waiting_industor_approval: { label: 'Awaiting Industor', color: 'warning' },
  waiting_tester_review: { label: 'Awaiting Tester', color: 'warning' },
  pending_payment: { label: 'Pending Payment', color: 'danger' },
  approved_by_tester: { label: 'Available', color: 'info' },
  accepted: { label: 'Accepted', color: 'primary' },
  modification_requested: { label: 'Modification Requested', color: 'warning' },
  in_progress: { label: 'In Progress', color: 'warning' },
  awaiting_qa: { label: 'Awaiting QA', color: 'secondary' },
  completed: { label: 'Completed', color: 'success' },
  rejected_qa: { label: 'Rejected by QA', color: 'danger' },
  rejected_by_industor: { label: 'Rejected by Industor', color: 'dark' },
  rejected_by_tester: { label: 'Rejected by Tester', color: 'dark' },
  cancelled: { label: 'Cancelled', color: 'dark' },
}

export function statusMeta(status) {
  return TICKET_STATUS[status] || { label: status, color: 'light' }
}

export function formatDate(value) {
  if (!value) return '-'
  return new Date(value).toLocaleString()
}
