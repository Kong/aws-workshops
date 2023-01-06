+++
title = "What is Kong Konnect?"
weight = 13
+++

Konnect is an API lifecycle management platform designed from the ground up for the cloud native era and delivered as a service. This platform lets you build modern applications better, faster, and more securely. The management plane is hosted in the cloud by Kong, while the runtime engine, Kong Gateway — Kong’s lightweight, fast, and flexible API gateway — is managed by you within your preferred network environment.

Kong Konnect is designed to run on decentralized architectures, leveraging workflow automation and modern GitOps practices. With Kong Konnect, users can:

* Offering a single management plane to deploy and manage your APIs and microservices in any environment: cloud, on-premises, Kubernetes, and virtual machines.
* Instantly applying authentication, API security, and traffic control policies consistently across all your services using powerful enterprise and community plugins.
* Providing a real-time, centralized view of all your services. Monitor golden signals such as error rate and latency for each service and route to gain deep insights into your API products.

Kong Konnect is a combination of several features and modules, as shown in the diagram and described in the next section, Kong Konnect Enterprise Features.

![introduction](/images/introduction.png)


## Kong Konnect Enterprise Features
Kong Gateway Enterprise features are described in this section, including modules and plugins that extend and enhance the functionality of the Kong Konnect platform.


### Service Hub
Service Hub makes internal APIs discoverable, consumable, and reusable for internal development teams. Catalog all your services through the Service Hub to create a single source of truth for your organization’s service inventory. By leveraging Service Hub, your application developers can search, discover, and consume existing services to accelerate their time-to-market, while enabling a more consistent end-user experience across the organization’s applications.

### Runtime Manager
Runtime Manager empowers your teams to securely collaborate and manage their own set of runtimes and services without the risk of impacting other teams and projects. Runtime Manager instantly provisions hosted Kong Gateway control planes and supports securely attaching Kong Gateway data planes from your cloud or hybrid environments.

Through the Runtime Manager, increase the security of your APIs with out-of-the-box enterprise and community plugins, including OpenID Connect, Open Policy Agent, Mutual TLS, and more.

### Dev Portal
Streamline developer onboarding with the Dev Portal, which offers a self-service developer experience to discover, register, and consume published services from your Service Hub catalog. This customizable experience can be used to match your own unique branding and highlights the documentation and interactive API specifications of your services. Enable application registration to automatically secure your APIs with a variety of authorization providers.

### Analytics
Use Analytics to gain deep insights into service, route, and application usage and health monitoring data. Keep your finger on the pulse of the health of your API products with custom reports and contextual dashboards. In addition, you can enhance the native monitoring and analytics capabilities with Kong Gateway plugins that enable streaming monitoring metrics to third-party analytics providers, such as Datadog and Prometheus.

### Teams
To help secure and govern your environment, Konnect provides the ability to manage authorization with teams. You can use Konnect’s predefined teams for a standard set of roles, or create custom teams with any roles you choose. Invite users and add them to these teams to manage user access. You can also map groups from your existing identity provider into Konnect teams.

### Kong Plugins
Kong Konnect plugins provide advanced functionality to better manage your API and microservices. With turnkey capabilities to meet the most challenging use cases, Kong Enterprise plugins ensure maximum control and minimizes unnecessary overhead. Enable features like authentication, rate-limiting, and transformations by enabling Kong Enterprise plugins. For more information on which plugins are Enterprise-only, see the [Kong Hub](https://docs.konghq.com/hub/).




## Key Concepts and Terminology
Kong Konnect Enterprise uses common terms for entities and processes that have a specific meaning in context. This topic provides a conceptual overview of terms, and how they apply to Kong’s use cases.

### Admin
An Admin is a Kong Konnect user account capable of accessing the Admin API or Kong Konnect UI. With RBAC, access can be modified and limited to specific entities.

### Authentication
Authentication is the process by which a system validates the identity of a user account. It is a separate concept from authorization.

API gateway authentication is an important way to control the data that is allowed to be transmitted to and from your APIs. An API may have a restricted list of identities that are authorized to access it. Authentication is the process of proving an identity.

### Authorization
Authorization is the system of defining access to certain resources. In Kong Gateway, Role-Based Access Control (RBAC) is the main authorization mode. To define authorization to an API, it is possible to use the ACL Plugin or OPA Plugin in conjunction with an authentication plugin.

### Client
A Kong Client refers to the downstream client making requests to Kong’s proxy port. It could be another service in a distributed application, a user’s identity, a user’s browser, or a specific device.

### Consumer
A Consumer object represents a client of a Service.

A Consumer is also the Admin API entity representing a developer or machine using the API. When using Kong, a Consumer only communicates with Kong which proxies every call to the said upstream API.

You can either rely on Kong as the primary datastore, or you can map the consumer list with your database to keep consistency between Kong and your existing primary datastore.

### Host
A Host represents the domain hosts (using DNS) intended to receive upstream traffic. In Kong, it is a list of domain names that match a Route object.

### Methods
Methods represent the HTTP methods available for requests. It accepts multiple values, for example, GET, POST, and DELETE. Its default value is empty (the HTTP method is not used for routing).

### Permission
A Permission is a policy representing the ability to create, read, update, or destroy an Admin API entity defined by endpoints.

### Plugin
Plugins provide advanced functionality and extend the use of Kong Gateway, allowing you to add new features to your gateway. Plugins can be configured to run in a variety of contexts, ranging from a specific route to all upstreams. Plugins can perform operations in your environment, such as authentication, rate-limiting, or transformations on a proxied request.

### Proxy
Kong Runtime is a reverse proxy that manages traffic between clients and hosts. As a gateway, Kong’s proxy functionality evaluates any incoming HTTP request against the Routes you have configured to find a matching one. If a given request matches the rules of a specific Route, Kong processes proxying the request. Because each Route is linked to a Service, Kong runs the plugins you have configured on your Route and its associated Service and then proxies the request upstream.

### Proxy Caching
One of the key benefits of using a reverse proxy is the ability to cache frequently-accessed content. The benefit is that upstream services do not need to waste computation on repeated requests.

One of the ways Kong delivers performance is through Proxy Caching, using the Proxy Cache Advanced Plugin. This plugin supports performance efficiency by providing the ability to cache responses based on requests, response codes and content type.

Kong receives a response from a service and stores it in the cache within a specific timeframe.

For future requests within the timeframe, Kong responds from the cache instead of the service.

The cache timeout is configurable. Once the time expires, Kong forwards the request to the upstream again, caches the result, and then responds from the cache until the next timeout.

The plugin can store cached data in-memory. The tradeoff is that it competes for memory with other processes, so for improved performance, use Redis for caching.

### Rate Limiting
Rate Limiting allows you to restrict how many requests your upstream services receive from your API consumers, or how often each user can call the API. Rate limiting protects the APIs from inadvertent or malicious overuse. Without rate limiting, each user may request as often as they like, which can lead to spikes of requests that starve other consumers. After rate limiting is enabled, API calls are limited to a fixed number of requests per second.

In this workflow, we are going to enable the Rate Limiting Advanced Plugin. This plugin provides support for the sliding window algorithm to prevent the API from being overloaded near the window boundaries and adds Redis support for greater performance.

### Role
A Role is a set of permissions that may be reused and assigned to Admins.

### Route
A Route, also referred to as Route object, defines rules to match client requests to upstream services. Each Route is associated with a Service, and a Service may have multiple Routes associated with it. Routes are entry-points in Kong and define rules to match client requests. Once a Route is matched, Kong proxies the request to its associated Service. See the Proxy Reference for a detailed explanation of how Kong proxies traffic.

### Service
A Service, also referred to as a Service object, is the upstream APIs and microservices Kong manages. Examples of Services include a data transformation microservice, a billing API, and so on. The main attribute of a Service is its URL (where Kong should proxy traffic to), which can be set as a single string or by specifying its protocol, host, port and path individually. The URL can be composed by specifying a single string or by specifying its protocol, host, port, and path individually.

Before you can start making requests against a Service, you need to add a Route to it. Routes specify how (and if) requests are sent to their Services after they reach Kong. A single Service can have many Routes. After configuring the Service and the Route, you’ll be able to make requests through Kong using them.

### Super Admin
A Super Admin can:

* Invite and disable other Admin accounts
* Assign and revoke Roles to Admins
* Create new Roles with custom Permissions

### Tags
Tags are customer defined labels that let you manage, search for, and filter core entities using the ?tags querystring parameter. Each tag must be composed of one or more alphanumeric characters, \_\, -, . or ~. Most core entities can be tagged via their tags attribute, upon creation or edition.

### Upstream
An Upstream object refers to your upstream API/service sitting behind Kong, to which client requests are forwarded. An Upstream object represents a virtual hostname and can be used to load balance incoming requests over multiple services (targets). For example, an Upstream named service.v1.xyz for a Service object whose host is service.v1.xyz. Requests for this Service object would be proxied to the targets defined within the upstream.



## Try Kong Konnect Enterprise
Kong Konnect is available in [free, plus and enterprise modes](https://konghq.com/pricing) 

Sign up for a free trial of [Kong Konnect Plus](https://cloud.konghq.com/register).

If you are interested in evaluating Enterprise features locally, the Kong sales team manages evaluation licenses as part of a formal sales process. The best way to get started with the sales process is to request a demo and indicate your interest.




