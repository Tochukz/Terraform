# Instance Scheduler on AWS

[Solution Guide](https://aws.amazon.com/solutions/implementations/instance-scheduler-on-aws/)  
[Implementation Guide](https://docs.aws.amazon.com/solutions/latest/instance-scheduler-on-aws/solution-overview.html)  
[Source Code](https://github.com/aws-solutions/instance-scheduler-on-aws/tree/main)

**Overview**  
The Instance Scheduler on AWS solution automates the starting and stopping of Amazon Elastic Compute Cloud (Amazon EC2) and Amazon Relational Database Service (Amazon RDS) instances.  
This solution helps reduce operational costs by stopping resources that are not in use and starting them when they are needed. The cost savings can be significant if you leave all of your instances running at full utilization continuously.

### Concept and definitions

**Schedule:** Group of 1 or more periods that an instance is bound by.  
**Period:** Running period(s) defined by a start and stop time.  
**Instance:** Amazon EC2 and Amazon RDS resouces that are able to be scheduled.  
**Regular Business Hours:** 9:00 to 17:00 (9am-5pm) on weekdays

### Well-Architected design framework

This section describes how the principles and best practices of the six pillar of the AWS Well-Architected Framework was applied when designing this solution.

**Operational excellence**

- The solution pushes metrics to Amazon CloudWatch to provide observability into its components (such as its infrastructure and Lambda functions).
- AWS X-Ray traces Lambda functions.
- SNS for error reporting.

**Security**

- All inter-service communications use IAM roles.
- All multi-account communications use IAM roles.
- All roles used by the solution follow least-privilege access.
- All data storage including DynamoDB tables have encryption at rest.

**Reliability**

- The solution uses serverless AWS services wherever possible (such as Lambda and DynamoDB) to ensure high availability and recovery from service failure.
- Data processing uses Lambda functions. The solution stores data in DynamoDB so it persists in multiple Availability Zones by default.

**Performance efficiency**

- The solution uses serverless architecture
- You can launch the solution in any AWS Region that supports the AWS services used in this solution (such as Lambda and DynamoDB).

**Cost optimization**

- The solution uses serverless architecture, and customers pay only for what they use.
- The compute layer defaults to Lambda, which uses a pay-per-use model.

**Sustainability**

- The solution uses managed and serverless services to minimize the environmental impact of the backend services.
- The solution’s serverless design is aimed at reducing carbon footprint compared to the footprint of continually operating on-premises servers.

### Architecture details

**Scheduler configuration table**
This solution creates an Amazon DynamoDB table that contains global configuration settings.
To modify these global configuration settings after the solution is deployed, update the AWS CloudFormation stack. Do not modify these values in the DynamoDB table to avoid conflict or _drift_.

**Time Zone**  
If you do not specify a time zone, the schedule will use the default time zone you specify when you launch the solution.  
See list of [time zones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).
