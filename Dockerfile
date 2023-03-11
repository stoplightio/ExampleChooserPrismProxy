## adapted from https://sourcery.ai/blog/python-docker/
FROM python:3.10-alpine as deps

# Install pipenv and compilation dependencies
RUN pip install pipenv

# Install python dependencies in /.venv
COPY Pipfile .
COPY Pipfile.lock .
RUN PIPENV_VENV_IN_PROJECT=1 pipenv install --deploy

FROM deps AS runtime

# Copy virtual env from python-deps stage
COPY --from=deps /.venv /.venv
ENV PATH="/.venv/bin:$PATH"

# Create and switch to a new user
RUN adduser -D appuser
RUN mkdir /home/appuser/app
WORKDIR /home/appuser/app
USER appuser

# Install application into container
COPY . .

# Run the application
CMD ["python", "-m", "flask", "run", "--host=0.0.0.0"]
