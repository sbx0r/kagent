package controller

import (
	"sigs.k8s.io/controller-runtime/pkg/event"
	"sigs.k8s.io/controller-runtime/pkg/predicate"

	ctrl "sigs.k8s.io/controller-runtime"
)

var predicateLog = ctrl.Log.WithName("predicates")

// NewNamespaceFilterPredicate creates a predicate that filters events based on
// a list of allowed namespaces. If the list is empty, all namespaces are allowed.
func NewNamespaceFilterPredicate(allowedNamespaces []string) predicate.Predicate {
	// If no namespaces specified, allow all
	if len(allowedNamespaces) == 0 {
		return predicate.Funcs{}
	}

	// Convert to map for quick lookup
	allowedMap := make(map[string]bool, len(allowedNamespaces))
	for _, ns := range allowedNamespaces {
		allowedMap[ns] = true
	}

	return predicate.Funcs{
		CreateFunc: func(e event.CreateEvent) bool {
			ns := e.Object.GetNamespace()
			allowed := allowedMap[ns]
			if !allowed {
				predicateLog.V(4).Info(
					"ignoring create event for resource in non-watched namespace",
					"namespace", ns,
					"kind", e.Object.GetObjectKind().GroupVersionKind().Kind,
					"name", e.Object.GetName(),
				)
			}
			return allowed
		},
		UpdateFunc: func(e event.UpdateEvent) bool {
			ns := e.ObjectNew.GetNamespace()
			allowed := allowedMap[ns]
			if !allowed {
				predicateLog.V(4).Info(
					"ignoring update event for resource in non-watched namespace",
					"namespace", ns,
					"kind", e.ObjectNew.GetObjectKind().GroupVersionKind().Kind,
					"name", e.ObjectNew.GetName(),
				)
			}
			return allowed
		},
		DeleteFunc: func(e event.DeleteEvent) bool {
			ns := e.Object.GetNamespace()
			allowed := allowedMap[ns]
			if !allowed {
				predicateLog.V(4).Info(
					"ignoring delete event for resource in non-watched namespace",
					"namespace", ns,
					"kind", e.Object.GetObjectKind().GroupVersionKind().Kind,
					"name", e.Object.GetName(),
				)
			}
			return allowed
		},
		GenericFunc: func(e event.GenericEvent) bool {
			ns := e.Object.GetNamespace()
			allowed := allowedMap[ns]
			if !allowed {
				predicateLog.V(4).Info(
					"ignoring generic event for resource in non-watched namespace",
					"namespace", ns,
					"kind", e.Object.GetObjectKind().GroupVersionKind().Kind,
					"name", e.Object.GetName(),
				)
			}
			return allowed
		},
	}
}
