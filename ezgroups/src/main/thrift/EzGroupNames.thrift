/*   Copyright (C) 2013-2014 Computer Sciences Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License. */

namespace java ezbake.groups.thrift
namespace cpp ezbake.groups.thrift
namespace py ezbake.groups.thrift
namespace js ezbake.groups.thrift

/*
 * Root Group name constants
 */
const string ROOT = "root"
const string APP_GROUP = "app"
const string APP_ACCESS_GROUP = "appaccess"

/*
 * App Special group names
 *
 * By convention, these will be created under:
 *
 *     root.app.<appName>.<special group name>
 *
 * ex:
 *     root.app.EzBake.ezbAudits
 *     root.app.EzBake.ezbMetrics
 *     root.app.EzBake.ezbDiagnostics
 *
 */
const string AUDIT_GROUP = "ezbAudits"
const string METRICS_GROUP = "ezbMetrics"
const string DIAGNOSTICS_GROUP = "ezbDiagnostics"

const string GROUP_NAME_SEP = "."
