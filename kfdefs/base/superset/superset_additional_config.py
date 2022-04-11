import ldap
import logging

FEATURE_FLAGS = {
    'ENABLE_TEMPLATE_PROCESSING': True,
    'DASHBOARD_RBAC': True,
    'DASHBOARD_CROSS_FILTERS': True,
    'DASHBOARD_NATIVE_FILTERS': True,
    'DASHBOARD_NATIVE_FILTERS_SET': False  # Set this to True once the flag is stable
}

AUTH_USER_REGISTRATION_ROLE = 'Datahub'
AUTH_ROLES_MAPPING = {
          'data-hub-openshift-admins': ['Admin'],
          'ccx-dev': ['CCX Sensitive', 'CCX'],
          'candlepin-posix': ['Subscriptions'],
          'ceeandpe': ['Subscriptions', 'CCX Sensitive', 'CCX'],
          'telemeter-auth': ['Telemetry', 'CCX'],
          'telemeter-auto-approval': ['Telemetry', 'CCX'],
          'telemeter-manual-approval': ['Telemetry', 'CCX'],
          'na-cs-tam-auto': ['CCX Sensitive', 'CCX'],
          'apac-cs-tam-auto': ['CCX Sensitive', 'CCX'],
          'latam-cs-tam-auto': ['CCX Sensitive', 'CCX'],
          'emea-cs-tam-auto': ['CCX Sensitive', 'CCX'],
          'na-ps-cs-tam-auto': ['CCX Sensitive', 'CCX'],
          'emea-cs-csm-auto': ['CCX Sensitive', 'CCX'],
          'emea-cs-cse-auto': ['CCX Sensitive', 'CCX'],
          'emea-cs-managers': ['CCX Sensitive', 'CCX'],
          'apac-cs-csm-auto': ['CCX Sensitive', 'CCX'],
          'apac-cs-cse-auto': ['CCX Sensitive', 'CCX'],
          'na-cs-csm-auto': ['CCX Sensitive', 'CCX'],
          'na-cs-cse-auto': ['CCX Sensitive', 'CCX'],
          'na-ps-cs-cse-auto': ['CCX Sensitive', 'CCX'],
          'latam-cs-csm-auto': ['CCX Sensitive', 'CCX'],
          'ccx-pm': ['CCX Sensitive', 'CCX'],
          'ccx-datalake-access': ['CCX'],
          'ccx-sensitive-datalake-access': ['CCX', 'CCX Sensitive'],
          'assisted-lakers': ['CCX', 'CCX Sensitive']
        }


class LdapInterface(object):
    '''Abstraction to handle interfacing with LDAP'''

    def __init__(self, uri):
        self.logger = logging.getLogger(self.__class__.__name__)
        self.uri = uri
        self.conn = self.connect()

    def connect(self):
        '''Connect to LDAP server and initialize the interface'''
        conn = ldap.initialize(self.uri)
        return conn

    def get_user(self, user):
        METADATA_FIELDS = ['memberOf', 'manager', 'rhatProduct',
                           'rhatSubproduct', 'rhatProject', 'rhatRnDComponent']
        '''Search LDAP server for a specific user and record their metadata'''
        res = self.conn.search_s('dc=redhat,dc=com',
                                 ldap.SCOPE_SUBTREE,
                                 f"uid={user}",
                                 METADATA_FIELDS)
        uid, metadata = res[0]
        metadata = self._decode_metadata(metadata)
        return LdapUserEntry(user, metadata)

    def _decode_metadata(self, metadata):
        if isinstance(metadata, str):
            return metadata
        if isinstance(metadata, bytes):
            return metadata.decode('utf-8')
        if isinstance(metadata, list):
            return [(self._decode_metadata(m)) for m in metadata]
        if isinstance(metadata, dict):
            decoded = {}
            for k, v in metadata.items():
                k = self._decode_metadata(k)
                v = self._decode_metadata(v)
                decoded[k] = v
            return decoded


class LdapUserEntry(object):
    '''Represents LDAP metadata for a single user'''

    def __init__(self, uid, user_info):
        self.logger = logging.getLogger(self.__class__.__name__)
        self.uid = uid
        self.user_info = user_info

    def _parse_from_ldap_str(self, item, data):
        split = data.split(",")
        for s in split:
            if s.startswith(item):
                return s.split("=")[1]

    def get_groups(self):
        '''Aggregate a list of LDAP groups this user is a member of'''
        groups = self.user_info.get('memberOf', [])
        return [self._parse_from_ldap_str("cn", x) for x in groups]


class DataHubSecurityManager(CustomSecurityManager):

    def get_user_ldap_groups(self, username):
        REDHAT_LDAP_SERVER = 'ldap://ldap.corp.redhat.com'
        conn = LdapInterface(REDHAT_LDAP_SERVER)
        user_id = username.split('@')[0]
        return conn.get_user(user_id).get_groups()

    def oauth_user_info(self, provider, response=None):
        user = super(DataHubSecurityManager, self).oauth_user_info(provider,
                                                                   response)
        ldap_groups = self.get_user_ldap_groups(user['username'])
        user['role_keys'] = ldap_groups
        if '@' in user['email']:
            user['username'] = user['email'].split('@')[0]
        return user


CUSTOM_SECURITY_MANAGER = DataHubSecurityManager
