import com.codahale.metrics.servlet.InstrumentedFilterContextListener;
import com.codahale.metrics.*;
import java.util.concurrent.TimeUnit;

import javax.servlet.*;

public class MyInstrumentedFilterContextListener extends InstrumentedFilterContextListener {
    public static final MetricRegistry REGISTRY = new MetricRegistry();

    ConsoleReporter reporter;

    @Override
    protected MetricRegistry getMetricRegistry() {
        return REGISTRY;
    }

     @Override
     public void contextInitialized(ServletContextEvent sce) {
	 super.contextInitialized(sce);
	reporter = ConsoleReporter.forRegistry(REGISTRY)
	    .convertRatesTo(TimeUnit.SECONDS)
	    .convertDurationsTo(TimeUnit.MILLISECONDS)
	    .build();
	reporter.start(10, TimeUnit.SECONDS);
    }
}
