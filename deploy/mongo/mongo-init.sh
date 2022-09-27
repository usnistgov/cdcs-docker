echo "Creating curator user..."
echo '
    use '${MONGO_INITDB_DATABASE}'
    db.createUser(
        {
            user: "'${MONGO_USER}'",
            pwd: "'${MONGO_PASS}'",
            roles: [ "readWrite" ]
        }
    )
    exit' | mongo
