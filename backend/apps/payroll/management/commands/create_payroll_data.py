"""
Management command to create sample payroll data for testing.
"""
from django.core.management.base import BaseCommand
from django.db import transaction
from django.utils import timezone
from datetime import datetime, timedelta
from decimal import Decimal
import random

from apps.payroll.models import Contract, PayrollPeriod, PayrollItem, PayrollEntry, PayrollEntryDetail
from apps.affiliation.models import Employee
from apps.core.models import User


class Command(BaseCommand):
    help = 'Create sample payroll data for testing'

    def add_arguments(self, parser):
        parser.add_argument(
            '--employees',
            type=int,
            default=5,
            help='Number of employees to create contracts for (default: 5)'
        )
        parser.add_argument(
            '--periods',
            type=int,
            default=3,
            help='Number of payroll periods to create (default: 3)'
        )
        parser.add_argument(
            '--clear',
            action='store_true',
            help='Clear existing payroll data before creating new data'
        )

    def handle(self, *args, **options):
        if options['clear']:
            self.stdout.write('Clearing existing payroll data...')
            PayrollEntryDetail.objects.all().delete()
            PayrollEntry.objects.all().delete()
            PayrollPeriod.objects.all().delete()
            PayrollItem.objects.all().delete()
            Contract.objects.all().delete()
            self.stdout.write(self.style.SUCCESS('Existing data cleared.'))

        with transaction.atomic():
            # Create admin user if doesn't exist
            admin_user = self.create_admin_user()
            
            # Create payroll items
            self.create_payroll_items()
            
            # Create payroll periods
            periods = self.create_payroll_periods(options['periods'])
            
            # Get employees and create contracts
            employees = self.get_or_create_employees(options['employees'])
            contracts = self.create_contracts(employees, admin_user)
            
            # Create payroll entries for first period
            if periods and contracts:
                self.create_payroll_entries(contracts, periods[0], admin_user)

        self.stdout.write(
            self.style.SUCCESS(
                f'Successfully created sample payroll data:\n'
                f'- {len(contracts)} contracts\n'
                f'- {len(periods)} periods\n'
                f'- Payroll items created\n'
                f'- Sample entries for first period'
            )
        )

    def create_admin_user(self):
        """Create or get admin user"""
        try:
            admin_user = User.objects.get(email='admin@rhplus.com')
        except User.DoesNotExist:
            admin_user = User.objects.create_user(
                email='admin@rhplus.com',
                password='admin123',
                first_name='Admin',
                last_name='RH Plus',
                is_staff=True,
                is_superuser=True
            )
            self.stdout.write(f'Created admin user: {admin_user.email}')
        
        return admin_user

    def create_payroll_items(self):
        """Create basic payroll items"""
        items_data = [
            # Earnings
            {'name': 'Salario Básico', 'code': 'BASIC_SALARY', 'item_type': 'EARNING', 'default_amount': 0},
            {'name': 'Horas Extra', 'code': 'OVERTIME', 'item_type': 'EARNING', 'default_amount': 50000},
            {'name': 'Bonificación', 'code': 'BONUS', 'item_type': 'EARNING', 'default_amount': 100000},
            {'name': 'Auxilio de Transporte', 'code': 'TRANSPORT', 'item_type': 'EARNING', 'default_amount': 140606},
            {'name': 'Prima de Servicio', 'code': 'SERVICE_BONUS', 'item_type': 'EARNING', 'default_amount': 0},
            
            # Deductions
            {'name': 'Salud (4%)', 'code': 'HEALTH', 'item_type': 'DEDUCTION', 'default_amount': 0, 'is_percentage': True},
            {'name': 'Pensión (4%)', 'code': 'PENSION', 'item_type': 'DEDUCTION', 'default_amount': 4, 'is_percentage': True},
            {'name': 'Retención en la Fuente', 'code': 'TAX_RETENTION', 'item_type': 'DEDUCTION', 'default_amount': 0},
            {'name': 'Préstamo', 'code': 'LOAN', 'item_type': 'DEDUCTION', 'default_amount': 50000},
            {'name': 'Descuento por Tardanza', 'code': 'LATE_DISCOUNT', 'item_type': 'DEDUCTION', 'default_amount': 0},
        ]

        created_count = 0
        for item_data in items_data:
            item, created = PayrollItem.objects.get_or_create(
                code=item_data['code'],
                defaults=item_data
            )
            if created:
                created_count += 1

        self.stdout.write(f'Created {created_count} payroll items')

    def create_payroll_periods(self, count):
        """Create payroll periods"""
        periods = []
        base_date = timezone.now().date().replace(day=1)  # First day of current month
        
        for i in range(count):
            # Calculate period dates (monthly periods)
            start_date = base_date - timedelta(days=i*30)
            end_date = start_date.replace(day=28) + timedelta(days=4)
            end_date = end_date - timedelta(days=end_date.day)  # Last day of month
            
            period, created = PayrollPeriod.objects.get_or_create(
                name=f'Período {start_date.strftime("%B %Y")}',
                defaults={
                    'period_type': 'MONTHLY',
                    'start_date': start_date,
                    'end_date': end_date,
                    'is_closed': i > 0  # Close older periods
                }
            )
            periods.append(period)

        self.stdout.write(f'Created {len(periods)} payroll periods')
        return periods

    def get_or_create_employees(self, count):
        """Get existing employees or create sample ones"""
        employees = list(Employee.objects.all()[:count])
        
        if len(employees) < count:
            # Create additional employees if needed
            needed = count - len(employees)
            self.stdout.write(f'Need to create {needed} more employees for testing')
            
            # Sample employee data
            sample_employees = [
                {'first_name': 'Juan', 'last_name': 'Pérez', 'email': 'juan.perez@company.com'},
                {'first_name': 'María', 'last_name': 'García', 'email': 'maria.garcia@company.com'},
                {'first_name': 'Carlos', 'last_name': 'Rodríguez', 'email': 'carlos.rodriguez@company.com'},
                {'first_name': 'Ana', 'last_name': 'Martínez', 'email': 'ana.martinez@company.com'},
                {'first_name': 'Luis', 'last_name': 'López', 'email': 'luis.lopez@company.com'},
                {'first_name': 'Carmen', 'last_name': 'Sánchez', 'email': 'carmen.sanchez@company.com'},
                {'first_name': 'Diego', 'last_name': 'Hernández', 'email': 'diego.hernandez@company.com'},
                {'first_name': 'Laura', 'last_name': 'González', 'email': 'laura.gonzalez@company.com'},            ]
            
            for i in range(needed):
                if i < len(sample_employees):
                    emp_data = sample_employees[i]
                    employee, created = Employee.objects.get_or_create(
                        email=emp_data['email'],
                        defaults={
                            'first_name': emp_data['first_name'],
                            'last_name': emp_data['last_name'],
                            'document_number': f'123456{i:03d}',
                            'document_type': 'CC',
                            'phone': f'300123{i:04d}',
                            'status': 'ACTIVE',
                            'employee_id': f'EMP{i:03d}',
                            'position': random.choice(['Desarrollador', 'Analista', 'Coordinador']),
                            'department': random.choice(['Desarrollo', 'Marketing', 'RRHH']),
                            'address': f'Calle {i+1} # {random.randint(10,99)}-{random.randint(10,99)}',
                            'hire_date': timezone.now().date() - timedelta(days=random.randint(30, 730))
                        }
                    )
                    if created:
                        employees.append(employee)
        
        return employees

    def create_contracts(self, employees, admin_user):
        """Create contracts for employees"""
        contracts = []
        departments = ['Desarrollo', 'Marketing', 'Ventas', 'RRHH', 'Administración']
        positions = ['Desarrollador', 'Analista', 'Coordinador', 'Especialista', 'Asistente']
        
        for i, employee in enumerate(employees):
            # Random salary between 1,000,000 and 5,000,000 COP
            salary = Decimal(random.randint(1000000, 5000000))
            
            contract, created = Contract.objects.get_or_create(
                employee=employee,
                defaults={
                    'contract_type': random.choice(['INDEFINITE', 'FIXED_TERM']),
                    'start_date': timezone.now().date() - timedelta(days=random.randint(30, 365)),
                    'salary': salary,
                    'currency': 'COP',
                    'position': random.choice(positions),
                    'department': random.choice(departments),
                    'work_schedule': 'FULL_TIME',
                    'is_active': True,
                    'created_by': admin_user
                }
            )
            
            if created:
                contracts.append(contract)

        self.stdout.write(f'Created {len(contracts)} contracts')
        return contracts

    def create_payroll_entries(self, contracts, period, admin_user):
        """Create sample payroll entries for a period"""
        entries_created = 0
        
        # Get payroll items
        basic_salary = PayrollItem.objects.get(code='BASIC_SALARY')
        transport = PayrollItem.objects.get(code='TRANSPORT')
        health = PayrollItem.objects.get(code='HEALTH')
        pension = PayrollItem.objects.get(code='PENSION')
        
        for contract in contracts:
            # Create payroll entry
            entry = PayrollEntry.objects.create(
                contract=contract,
                period=period,
                base_salary=contract.salary,
                total_earnings=Decimal('0.00'),
                total_deductions=Decimal('0.00'), 
                net_pay=Decimal('0.00'),
                created_by=admin_user
            )
            
            # Add basic salary
            PayrollEntryDetail.objects.create(
                payroll_entry=entry,
                payroll_item=basic_salary,
                amount=contract.salary,
                quantity=1,
                notes='Salario básico mensual'
            )
            
            # Add transport allowance (if salary is low enough)
            if contract.salary <= Decimal('2640000'):  # 2 minimum wages
                PayrollEntryDetail.objects.create(
                    payroll_entry=entry,
                    payroll_item=transport,
                    amount=transport.default_amount,
                    quantity=1,
                    notes='Auxilio de transporte'
                )
            
            # Add health deduction (4% of salary)
            health_amount = contract.salary * Decimal('0.04')
            PayrollEntryDetail.objects.create(
                payroll_entry=entry,
                payroll_item=health,
                amount=health_amount,
                quantity=1,
                notes='Descuento salud 4%'
            )
            
            # Add pension deduction (4% of salary)
            pension_amount = contract.salary * Decimal('0.04')
            PayrollEntryDetail.objects.create(
                payroll_entry=entry,
                payroll_item=pension,
                amount=pension_amount,
                quantity=1,
                notes='Descuento pensión 4%'
            )
            
            # Randomly add overtime or bonus for some employees
            if random.choice([True, False]):
                overtime = PayrollItem.objects.get(code='OVERTIME')
                overtime_hours = random.randint(5, 20)
                PayrollEntryDetail.objects.create(
                    payroll_entry=entry,
                    payroll_item=overtime,
                    amount=overtime.default_amount,
                    quantity=overtime_hours,
                    notes=f'Horas extra: {overtime_hours} horas'
                )
            
            # Calculate totals
            entry.calculate_totals()
            
            # Randomly approve some entries
            if random.choice([True, False]):
                entry.approve(admin_user)
            
            entries_created += 1

        self.stdout.write(f'Created {entries_created} payroll entries with details')
