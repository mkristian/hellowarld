import com.codahale.metrics.servlets.*;
import com.codahale.metrics.*;

public class MyMetricsServletContextListener extends MetricsServlet.ContextListener {

    @Override
    protected MetricRegistry getMetricRegistry() {
        return MyInstrumentedFilterContextListener.REGISTRY;
    }

}
