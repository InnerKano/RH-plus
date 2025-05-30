from apps.payroll.models import Contract, PayrollPeriod

# Get Contract data
print(f"💼 Getting Contracts...")
contracts = Contract.objects.all()
print(f"Found {contracts.count()} Contracts:")
for contract in contracts:
    print(f"  ID: {contract.id} - Employee ID: {contract.employee.id} - Salary: ${contract.salary}")

# Get PayrollPeriod data
print(f"📅 Getting PayrollPeriods...")
periods = PayrollPeriod.objects.all()
print(f"Found {periods.count()} PayrollPeriods:")
for period in periods:
    print(f"  ID: {period.id} - {period.name} - Status: {period.status}")
