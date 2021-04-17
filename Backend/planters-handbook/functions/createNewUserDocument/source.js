exports = async function createNewUserDocument({user}) {
  const cluster = context.services.get("mongodb-atlas");
  const users = cluster.db("planters-handbook").collection("User");
  return users.insertOne({
    _id: user.id,
    _partition: `user=${user.id}`,
    name: user.data.email,
    canReadPartitions: [`user=${user.id}`],
    canWritePartitions: [`season=${user.id}`, `entry=${user.id}`, `block=${user.id}`, `subBlock=${user.id}`],
    company: '',
  });
};
