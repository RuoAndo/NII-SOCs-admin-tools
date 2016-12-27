import com.datastax.driver.core.Cluster;
import com.datastax.driver.core.Host;
import com.datastax.driver.core.Metadata;
import com.datastax.driver.core.Session;
import static java.lang.System.out;

public class CassandraConnector
{
    /** Cassandra Cluster. */
    private Cluster cluster;
    /** Cassandra Session. */
    private Session session;

    public void main(final String node, final int port)
    {
	this.cluster = Cluster.builder().addContactPoint(node).withPort(port).build();
	final Metadata metadata = cluster.getMetadata();
	out.printf("Connected to cluster: %s\n", metadata.getClusterName());
	for (final Host host : metadata.getAllHosts())
	    {
		out.printf("Datacenter: %s; Host: %s; Rack: %s\n",
			   host.getDatacenter(), host.getAddress(), host.getRack());
	    }
	session = cluster.connect();
    }

    public Session getSession()
    {
	return this.session;
    }

    public void close()
    {
	cluster.close();
    }
}
