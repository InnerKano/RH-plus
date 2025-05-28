import logging
from django.conf import settings

# Configurar el logger para el módulo de training
logger = logging.getLogger('training')

if not settings.DEBUG:
    # Handler para archivo
    file_handler = logging.FileHandler('training.log')
    file_handler.setLevel(logging.INFO)
    file_formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    file_handler.setFormatter(file_formatter)
    logger.addHandler(file_handler)

# Handler para consola
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.INFO)
console_formatter = logging.Formatter(
    '%(levelname)s - %(message)s'
)
console_handler.setFormatter(console_formatter)
logger.addHandler(console_handler)

logger.setLevel(logging.INFO)
