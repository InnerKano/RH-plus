"""
Logging configuration for payroll app.
"""
import logging
import sys
from django.conf import settings

def setup_payroll_logging():
    """Setup specific logging configuration for payroll module."""
    
    # Create logger for payroll
    logger = logging.getLogger('apps.payroll')
    logger.setLevel(logging.INFO)
    
    # Avoid duplicate logs if already configured
    if logger.handlers:
        return logger
    
    # Create console handler
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(logging.INFO)
    
    # Create formatter
    formatter = logging.Formatter(
        '[PAYROLL] %(asctime)s - %(levelname)s - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    console_handler.setFormatter(formatter)
    
    # Add handler to logger
    logger.addHandler(console_handler)
    
    # Prevent propagation to root logger to avoid duplicates
    logger.propagate = False
    
    return logger

# Initialize logging when module is imported
setup_payroll_logging()
