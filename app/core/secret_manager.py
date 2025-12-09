from google.cloud import secretmanager
from app.core.config import settings
from app.core.logger import get_logger
import os

logger = get_logger(__name__)

def get_secret(secret_name: str, project_id: str = None) -> str:
    """
    Retrieve a secret from GCP Secret Manager.
    """
    if not project_id:
        project_id = settings.GCP_PROJECT
        
    if not project_id:
        logger.warning("GCP_PROJECT not set, cannot fetch secrets from Secret Manager.")
        return ""

    client = secretmanager.SecretManagerServiceClient()
    name = f"projects/{project_id}/secrets/{secret_name}/versions/latest"

    try:
        response = client.access_secret_version(request={"name": name})
        return response.payload.data.decode("UTF-8")
    except Exception as e:
        logger.error(f"Failed to fetch secret {secret_name}: {e}")
        return ""

def bootstrap_secrets_to_env(secret_names: list[str]):
    """
    Fetch secrets and write them to .env file or set in environment.
    """
    # For this implementation, we will set them in the environment variables of the current process
    # and also return them if needed.
    for name in secret_names:
        # Map secret name to env var name (simple uppercase mapping for now)
        # In reality, you might want a mapping dict.
        # Here we assume the secret name in GCP matches the config variable name (e.g. binance_api_key)
        # But config expects BINANCE_API_KEY.
        
        # Let's assume the secret name passed here is the GCP secret name.
        value = get_secret(name)
        if value:
            # Heuristic: convert "binance_api_key" -> "BINANCE_API_KEY"
            env_var = name.upper()
            os.environ[env_var] = value
            logger.info(f"Loaded secret {name} into env var {env_var}")
